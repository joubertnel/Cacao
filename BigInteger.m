//
//  BigInteger.m
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

#import "BigInteger.h"

#define PREP_MPZ_OPS(ropMpz, thisMpz, otherMpz, thisBigInt, otherBigInt) \
    mpz_t ropMpz; \
    mpz_t thisMpz; \
    mpz_t otherMpz; \
    mpz_init(ropMpz); \
    mpz_init(thisMpz); \
    mpz_init(otherMpz); \
    mpz_import(thisMpz, [thisBigInt mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, [[thisBigInt mpzData] bytes]); \
    mpz_import(otherMpz, [otherBigInt mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, [[otherBigInt mpzData] bytes]);

#define END_MPZ_OPS(ropMpz, thisMpz, otherMpz) \
    mpz_clear(ropMpz); \
    mpz_clear(thisMpz); \
    mpz_clear(otherMpz); 


static const int MSB_ORDER = 1;


@implementation BigInteger

@synthesize mpzData;
@synthesize base;
@synthesize mpzDataWordCount;

#pragma mark Lifetime management


+ (BigInteger *)bigIntegerWithMPZ:(mpz_t)mpz base:(int)theBase
{    
    size_t count;
    unsigned char * data = mpz_export(NULL, &count, MSB_ORDER, sizeof(long long), 0, 0, mpz);   
    NSData * theMpzData = [NSData dataWithBytes:data length:count*sizeof(long long)];
    free(data);
    
    BigInteger * bigInteger = [[BigInteger alloc] init];    
    [bigInteger setMpzData:theMpzData];
    [bigInteger setBase:theBase];
    [bigInteger setMpzDataWordCount:count];
    return [bigInteger autorelease];
}

+ (BigInteger *)bigIntegerWithMPZ:(mpz_t)mpz
{
    return [BigInteger bigIntegerWithMPZ:mpz base:10];
}


+ (id)bigIntegerWithValue:(NSString *)theValue base:(int)theBase
{
    mpz_t theNumber;
    const char * valStr = [theValue cStringUsingEncoding:NSUTF8StringEncoding];
    
    mpz_init_set_str(theNumber, valStr, theBase);
    BigInteger * bigInteger = [BigInteger bigIntegerWithMPZ:theNumber base:theBase];
    mpz_clear(theNumber);
    return bigInteger;
}

+ (BigInteger *)bigIntegerWithValue:(NSString *)theValue
{
	return [BigInteger bigIntegerWithValue:theValue base:10];
}


- (void)negate
{
//    mpz_t the_mpz;
//	mpz_t neg_mpz;
//    [self.mpzVal getValue:&the_mpz];
//    
//	mpz_init (neg_mpz);
//	mpz_neg (neg_mpz, the_mpz);
//    mpz_clear (the_mpz);
//    
//    [self setMpzVal:[NSValue value:neg_mpz withObjCType:@encode(mpz_t)]];
}

//- (void)dealloc
//{
//    mpz_t theNumber;
//    [self.mpzVal getValue:&theNumber];
//	mpz_clear (theNumber);
//	[super dealloc];
//}


- (NSString *)printable
{
    const unsigned char * data = [self.mpzData bytes];
    
    mpz_t number;
    mpz_init(number);
    mpz_import(number, [self mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, data);
    
    char * numStr = mpz_get_str(NULL, self.base, number);    
    mpz_clear(number);
    NSString * readable = [NSString stringWithCString:numStr encoding:NSASCIIStringEncoding];
    free(numStr);
    return [readable autorelease];
}


#pragma mark Equality

- (int)compareGMP:(mpz_t)aGMPBigInteger
{
    const unsigned char * data = [self.mpzData bytes];
    mpz_t this_mpz;
    mpz_init(this_mpz);
    mpz_import(this_mpz, [self mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, data);    
    
    int compareResult = mpz_cmp (this_mpz, aGMPBigInteger);
    mpz_clear(this_mpz);
    return compareResult;
}

- (NSComparisonResult)compare:(BigInteger *)otherBigInteger
{
    const unsigned char * data = [otherBigInteger.mpzData bytes];
    mpz_t other_mpz;
    mpz_init(other_mpz);
    mpz_import(other_mpz, [otherBigInteger mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, data);
    
	int compareResult = [self compareGMP:other_mpz];
    mpz_clear(other_mpz);
	
	if (compareResult < 0)
		return NSOrderedDescending; // the otherBigInteger is larger, so this is smaller
	else if (compareResult > 0)
		return NSOrderedAscending; // the otherBigInteger is smaller, so this is larger
	else return NSOrderedSame;
		
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[BigInteger class]])
        return NO;
    
    return ([self compare:object] == NSOrderedSame);
}

- (BOOL)isLessThan:(BigInteger *)number
{
    return ([self compare:number] == NSOrderedDescending);
}


#pragma mark Arithmetic 

- (BigInteger *)add:(BigInteger *)anotherNumber
{
    PREP_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, anotherNumber);        
    mpz_add(result_mpz, this_mpz, other_mpz);    
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}

- (BigInteger *)subtract:(BigInteger *)anotherNumber
{
    PREP_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, anotherNumber);
    mpz_sub(result_mpz, this_mpz, other_mpz);
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}

- (BigInteger *)multiply:(BigInteger *)anotherNumber
{
    PREP_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, anotherNumber);
    mpz_mul(result_mpz, this_mpz, other_mpz);
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}

- (BigInteger *)divide:(BigInteger *)divisor
{
    PREP_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, divisor);
    mpz_div(result_mpz, this_mpz, other_mpz);
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}




@end
