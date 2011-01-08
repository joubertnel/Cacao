//
//  BigInteger.m
//  Cacao
//
//    Copyright 2010, 2011, Joubert Nel. All rights reserved.
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

static const int MSB_ORDER = 1;

#pragma mark MPZ (GMP Arbitrary Precision Integer) macros

#define PREP_MPZ(thisMpz, bigInteger) \
    mpz_t thisMpz; \
    mpz_init(thisMpz); \
    mpz_import(thisMpz, [bigInteger mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, [[bigInteger mpzData] bytes]); \
    if ([bigInteger isNegative]) mpz_neg(thisMpz, thisMpz);

#define END_MPZ(thisMpz) mpz_clear(thisMpz);    


#define PREP_ONE_MPZ_OP(ropMpz, thisMpz, thisBigInt) \
    mpz_t ropMpz; \
    mpz_t thisMpz; \
    mpz_init(ropMpz); \
    mpz_init(thisMpz); \
    mpz_import(thisMpz, [thisBigInt mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, [[thisBigInt mpzData] bytes]); \
    if ([thisBigInt isNegative]) mpz_neg(thisMpz, thisMpz);

#define END_ONE_MPZ_OP(ropMpz, thisMpz) \
    mpz_clear(ropMpz); \
    mpz_clear(thisMpz); 

#define PREP_TWO_MPZ_OPS(ropMpz, thisMpz, otherMpz, thisBigInt, otherBigInt) \
    mpz_t ropMpz; \
    mpz_t thisMpz; \
    mpz_t otherMpz; \
    mpz_init(ropMpz); \
    mpz_init(thisMpz); \
    mpz_init(otherMpz); \
    mpz_import(thisMpz, [thisBigInt mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, [[thisBigInt mpzData] bytes]); \
    mpz_import(otherMpz, [otherBigInt mpzDataWordCount], MSB_ORDER, sizeof(long long), 0, 0, [[otherBigInt mpzData] bytes]); \
    if ([thisBigInt isNegative]) mpz_neg(thisMpz, thisMpz); \
    if ([otherBigInt isNegative]) mpz_neg(otherMpz, otherMpz); 

#define END_TWO_MPZ_OPS(ropMpz, thisMpz, otherMpz) \
    mpz_clear(ropMpz); \
    mpz_clear(thisMpz); \
    mpz_clear(otherMpz); 


@implementation BigInteger

@synthesize mpzData;
@synthesize base;
@synthesize mpzDataWordCount;
@synthesize isNegative;

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
    if (mpz_sgn(mpz) < 0) [bigInteger setIsNegative:YES];
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

- (id)copyWithZone:(NSZone *)zone
{
    PREP_MPZ(number, self);
    BigInteger * aCopy = [BigInteger bigIntegerWithMPZ:number];
    END_MPZ(number);
    return aCopy;
}

- (NSString *)printable
{
    PREP_MPZ(number, self);   
    char * numStr = mpz_get_str(NULL, self.base, number);    
    END_MPZ(number);
    
    NSString * readable = [NSString stringWithCString:numStr encoding:NSASCIIStringEncoding];
    free(numStr);
    return [readable autorelease];
}


#pragma mark Equality

- (int)compareGMP:(mpz_t)aGMPBigInteger
{
    PREP_MPZ(this_mpz, self);   
    int compareResult = mpz_cmp (this_mpz, aGMPBigInteger);
    END_MPZ(this_mpz);
    return compareResult;
}

- (NSComparisonResult)compare:(BigInteger *)otherBigInteger
{
    PREP_MPZ(other_mpz, otherBigInteger);
	int compareResult = [self compareGMP:other_mpz];
    END_MPZ(other_mpz);
	
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
    PREP_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, anotherNumber);        
    mpz_add(result_mpz, this_mpz, other_mpz);    
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}

- (BigInteger *)subtract:(BigInteger *)anotherNumber
{
    PREP_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, anotherNumber);
    mpz_sub(result_mpz, this_mpz, other_mpz);
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}

- (BigInteger *)multiply:(BigInteger *)anotherNumber
{
    PREP_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, anotherNumber);
    mpz_mul(result_mpz, this_mpz, other_mpz);
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}

- (BigInteger *)divide:(BigInteger *)divisor
{
    PREP_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz, self, divisor);
    mpz_div(result_mpz, this_mpz, other_mpz);
    BigInteger * answer = [BigInteger bigIntegerWithMPZ:result_mpz];
    END_TWO_MPZ_OPS(result_mpz, this_mpz, other_mpz);
    return answer;
}




@end
