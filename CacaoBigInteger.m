//
//  CacaoBigInteger.m
//  Cacao
//
//    Copyright 2010, Joubert Nel. All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification, are
//    permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other materials
//    provided with the distribution.
//
//    THIS SOFTWARE IS PROVIDED BY JOUBERT NEL "AS IS'' AND ANY EXPRESS OR IMPLIED
//    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOUBERT NEL OR
//    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//    The views and conclusions contained in the software and documentation are those of the
//    authors and should not be interpreted as representing official policies, either expressed
//    or implied, of Joubert Nel.

#import "CacaoBigInteger.h"
#import "CacaoUtil.h"
#import <OpenCL/OpenCL.h>


const char * kernelSource = \
"__kernel void add(__global long *a, __global long *b, __global long *answer, const unsigned int a_count, const unsigned int b_count)" \
"{                                      " \
"  int gid = get_global_id(0);          " \
"  long a_val = 0;                      " \
"  if (gid < a_count) a_val = a[gid];   " \
"  long b_val = 0;                      " \
"  if (gid < b_count) b_val = b[gid];   " \
"  answer[gid] = a_val + b_val;         " \
"}";


// Big Integers are represented internally by reverse-ordered digit groups of long long numbers,
// limited to 18 digits. Normally long long numbers (64 bit ints) can be up to 19 digits, but 
// we limit our representation to 18 digits so that we can also store a carry digit during
// computations, such as during addition.
static const int DIGIT_GROUP_LENGTH = 18; 

// This is the largest number that will get stored in a digit group
static const long long NON_CARRY_LIMIT = 999999999999999999; // eighteen 9's
static const long long CARRY_REMOVE = NON_CARRY_LIMIT + 1;

static cl_device_id opencl_device;
static cl_context opencl_context;
static cl_program opencl_program;
static cl_kernel opencl_add_kernel;


@implementation CacaoBigInteger

@synthesize textual;
@synthesize groups;

+ (void)initialize
{
    // Set up OpenCL for use on the GPU, including compilation of the OpenCL
    // program that contains the kernels used by the CacaoBigInteger class.
    // We don't free these objects, since they are used throughout the lifetime
    // of the process. The OS cleans them up when the process exits. 
    
    cl_int err;
    
    err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_GPU, 1, &opencl_device, NULL);
    assert(err == CL_SUCCESS);
    opencl_context = clCreateContext(0, 1, &opencl_device, NULL, NULL, &err);
    assert(err == CL_SUCCESS);
    
    opencl_program = clCreateProgramWithSource(opencl_context, 1, (const char**)&kernelSource, NULL, &err);
    assert(err == CL_SUCCESS);
    err = clBuildProgram(opencl_program, 0, NULL, NULL, NULL, NULL);
    assert(err == CL_SUCCESS);    
    opencl_add_kernel = clCreateKernel(opencl_program, "add", &err);
    assert(err == CL_SUCCESS);
    assert(opencl_add_kernel != NULL);
}

+ (NSArray *)getGroupsReverseOrder:(NSString *)text
{   
    NSString * paddedText;
    int leadingZeroCount = DIGIT_GROUP_LENGTH - ([text length] % DIGIT_GROUP_LENGTH);
    
    if (leadingZeroCount == DIGIT_GROUP_LENGTH)
        paddedText = text;
    else {        
        NSString * padding = [CacaoUtil stringWithRepeatCharacter:'0' times:leadingZeroCount];
        paddedText = [NSString stringWithFormat:@"%@%@", padding, text];
    }

    int groupCount = [paddedText length] / DIGIT_GROUP_LENGTH;
    NSMutableArray * digitGroups = [NSMutableArray arrayWithCapacity:groupCount]; 
    
    NSUInteger firstLocation = (groupCount-1) * DIGIT_GROUP_LENGTH;
    NSRange range = {.length = DIGIT_GROUP_LENGTH, .location=firstLocation};
    for (int groupNumber=0; groupNumber < groupCount; groupNumber++) {       
        NSString * groupText = [paddedText substringWithRange:range];

        [digitGroups addObject:[NSNumber numberWithLongLong:[groupText longLongValue]]];
        range.location -= DIGIT_GROUP_LENGTH;
    }
    return [NSArray arrayWithArray:digitGroups];
}

+ (CacaoBigInteger *)bigIntegerFromText:(NSString *)text
{
    CacaoBigInteger * bigInt = [[CacaoBigInteger alloc] init];
    [bigInt setTextual:text];
   
    // A CacaoBigInteger is represented internally by groups of 'long long' values (64 bit integers)
    // stored in reverse order.
    [bigInt setGroups:[CacaoBigInteger getGroupsReverseOrder:text]];    
    return [bigInt autorelease];    
}

+ (CacaoBigInteger *)bigIntegerFromDigitGroups:(NSArray *)digitGroups
{
    CacaoBigInteger * bigInt = [[CacaoBigInteger alloc] init];
    [bigInt setGroups:digitGroups];
    return [bigInt autorelease];    
}

- (CacaoBigInteger *)add:(CacaoBigInteger *)number
{        
    int thisNumberGroupCount = [self.groups count];
    int otherNumberGroupCount = [number.groups count];
    
    // Short circuit if this number is zero
    if (thisNumberGroupCount == 1)
    {
        if ([[self.groups objectAtIndex:0] longLongValue] == 0)
            return number; // return the other number because adding zero to it keeps it unchanged
    }
    
    // Short circuit if the other number is zero
    if (otherNumberGroupCount == 1)
    {
        if ([[number.groups objectAtIndex:0] longLongValue] == 0)
            return self; // return this number because adding zero to it keeps it unchanged
    }
    
    int resultGroupCount = thisNumberGroupCount + 1;
    if (otherNumberGroupCount > resultGroupCount)
        resultGroupCount = otherNumberGroupCount + 1;
    
    long long a_buffer[thisNumberGroupCount]; // an array of this number's digit groups
    long long b_buffer[otherNumberGroupCount]; // an array of the digit groups of the number to add to this
    long long results[resultGroupCount]; // array that will hold the digit groups of the sum
    
    size_t global_work_size;
    
    cl_int err;

    cl_mem a_mem;
    cl_mem b_mem;
    cl_mem result_mem;

    cl_command_queue opencl_commands;    
    
    opencl_commands = clCreateCommandQueue(opencl_context, opencl_device, 0, &err);
    assert(err == CL_SUCCESS);
    
    a_mem = clCreateBuffer(opencl_context, CL_MEM_READ_ONLY, sizeof(long long) * thisNumberGroupCount, NULL, NULL);
    b_mem = clCreateBuffer(opencl_context, CL_MEM_READ_ONLY, sizeof(long long) * otherNumberGroupCount, NULL, NULL);
    result_mem = clCreateBuffer(opencl_context, CL_MEM_READ_WRITE, sizeof(long long) * resultGroupCount, NULL, NULL);
    assert(a_mem != NULL);
    assert(b_mem != NULL);
    assert(result_mem != NULL);

    // Put this number's digit groups into an OpenCL write buffer on the command queue.
    for (int i=0; i < thisNumberGroupCount; i++) 
        a_buffer[i] = [(NSNumber *)[self.groups objectAtIndex:i] longLongValue];
    err = clEnqueueWriteBuffer(opencl_commands, a_mem, CL_TRUE, 0, sizeof(a_buffer), a_buffer, 0, NULL, NULL);
    assert(err == CL_SUCCESS);
    
    // Put the second number's digit groups into an OpenCL write buffer on the command queue.
    for (int i=0; i < otherNumberGroupCount; i++)
        b_buffer[i] = [(NSNumber *)[number.groups objectAtIndex:i] longLongValue];
    err = clEnqueueWriteBuffer(opencl_commands, b_mem, CL_TRUE, 0, sizeof(b_buffer), b_buffer, 0, NULL, NULL);
    assert(err == CL_SUCCESS);
    
    // We need to tell the command queue how many digit groups there are in each of the two 
    // buffers.
    unsigned int a_count = thisNumberGroupCount;
    unsigned int b_count = otherNumberGroupCount;
    
    err = 0;
    err = clSetKernelArg(opencl_add_kernel, 0, sizeof(cl_mem), &a_mem);
    err |= clSetKernelArg(opencl_add_kernel, 1, sizeof(cl_mem), &b_mem);
    err |= clSetKernelArg(opencl_add_kernel, 2, sizeof(cl_mem), &result_mem);
    err |= clSetKernelArg(opencl_add_kernel, 3, sizeof(unsigned int), &a_count);
    err |= clSetKernelArg(opencl_add_kernel, 4, sizeof(unsigned int), &b_count);
    assert(err == CL_SUCCESS);
    
    // Go ahead and execute the command queue, summing the corresponding digits groups of the two numbers
    // that we want to add together in parallel. 
    global_work_size = resultGroupCount;
    err = clEnqueueNDRangeKernel(opencl_commands, opencl_add_kernel, 1, NULL, &global_work_size, NULL, 0, NULL, NULL);
    assert(err == CL_SUCCESS);
    
    clFinish(opencl_commands);

    err = clEnqueueReadBuffer(opencl_commands, result_mem, CL_TRUE, 0, sizeof(results), results, 0, NULL, NULL);
    assert(err == CL_SUCCESS);
    
    // Although we could add the digit groups in parallel, updating each digit group for carry over
    // must be done sequentially. 
    NSMutableArray * answerDigitGroups = [NSMutableArray arrayWithCapacity:resultGroupCount];
    for (int i=0; i < resultGroupCount; i++)
    {
        long long groupVal = results[i];
        if ((groupVal > NON_CARRY_LIMIT) && (i <= (resultGroupCount)))
        {
            groupVal = groupVal - CARRY_REMOVE;
            results[i+1] = results[i+1] + 1;
        }        
        [answerDigitGroups insertObject:[NSNumber numberWithLongLong:groupVal] atIndex:i];
    }
    
    CacaoBigInteger * answer = [CacaoBigInteger bigIntegerFromDigitGroups:answerDigitGroups];
            
    // Free up the memory we allocated
    assert(clReleaseMemObject(result_mem) == CL_SUCCESS);
    assert(clReleaseMemObject(b_mem) == CL_SUCCESS);
    assert(clReleaseMemObject(a_mem) == CL_SUCCESS);    
    assert(clReleaseCommandQueue(opencl_commands) == CL_SUCCESS);

    return answer;
}

- (void)negate
{
    @throw [NSException exceptionWithName:@"NotImplementedException" reason:@"Not Implemented Yet" userInfo:nil];
}


- (NSString *)printable
{
    if (self.textual == nil)
    {
        //Create a textual representation of the result.    
        int digitGroupCount = [self.groups count];
        NSMutableString * numberAsText = [NSMutableString stringWithCapacity:digitGroupCount * DIGIT_GROUP_LENGTH];
        for (int i=digitGroupCount-1; i >= 0; i--)
        {
            long long groupValue = [[self.groups objectAtIndex:i] longLongValue];
            if (groupValue != 0)
                [numberAsText appendFormat:@"%qi", groupValue];
        }
        [self setTextual:[NSString stringWithString:numberAsText]];
    }
    return [self textual];
}

@end
