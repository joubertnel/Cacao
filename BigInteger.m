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


@implementation BigInteger

@synthesize mpzVal;
@synthesize base;

#pragma mark Lifetime management

- (id)initWithMPZ:(mpz_t)mpz base:(int)theBase
{
    self = [super init];
    [self setMpzVal:[NSValue value:mpz withObjCType:@encode(mpz_t)]];
    [self setBase:theBase];
	return self;
}

- (id)init:(NSString *)theValue base:(int)theBase
{
	NSData *valueData = [NSData dataWithBytes:[theValue cStringUsingEncoding:NSUTF8StringEncoding]
									   length:[theValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    mpz_t theNumber;	
	mpz_init_set_str (theNumber, [valueData bytes], theBase);
    return [self initWithMPZ:theNumber base:theBase];
}

+ (BigInteger *)bigIntegerWithMPZ:(mpz_t)mpz
{
    BigInteger * bigInteger = [[BigInteger alloc] initWithMPZ:mpz base:10];
    return [bigInteger autorelease];
}

+ (id)bigIntegerWithValue:(NSString *)theValue
{
	return [BigInteger bigIntegerWithValue:theValue base:10];
}

+ (id)bigIntegerWithValue:(NSString *)theValue base:(int)theBase
{
    BigInteger * bigInteger = [[BigInteger alloc] init:theValue base:theBase];
    return [bigInteger autorelease];
}


- (void)negate
{
    mpz_t the_mpz;
	mpz_t neg_mpz;
    [self.mpzVal getValue:&the_mpz];
    
	mpz_init (neg_mpz);
	mpz_neg (neg_mpz, the_mpz);
    mpz_clear (the_mpz);
    
    [self setMpzVal:[NSValue value:neg_mpz withObjCType:@encode(mpz_t)]];
}

- (void)dealloc
{
    mpz_t theNumber;
    [self.mpzVal getValue:&theNumber];
	mpz_clear (theNumber);
	[super dealloc];
}


- (NSString *)printable
{
    mpz_t number;
    [self.mpzVal getValue:&number];
    char * numStr = mpz_get_str(NULL, self.base, number);
    NSString * readable = [NSString stringWithCString:numStr encoding:NSASCIIStringEncoding];
    return readable;
}


#pragma mark Equality

- (int)compareGMP:(mpz_t)aGMPBigInteger
{
    mpz_t this_mpz;
    [self.mpzVal getValue:&this_mpz];
	return mpz_cmp (this_mpz, aGMPBigInteger);
}

- (NSComparisonResult)compare:(BigInteger *)otherBigInteger
{
    mpz_t other_mpz;
    [otherBigInteger.mpzVal getValue:&other_mpz];
    
	int compareResult = [self compareGMP:other_mpz];
	
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
    mpz_t result_mpz;
    mpz_t this_mpz;
    mpz_t other_mpz;
    
    mpz_init(result_mpz);
    [self.mpzVal getValue:&this_mpz];
    [anotherNumber.mpzVal getValue:&other_mpz];
    
    mpz_add(result_mpz, this_mpz, other_mpz);    
    return [BigInteger bigIntegerWithMPZ:result_mpz];
}

- (BigInteger *)subtract:(BigInteger *)anotherNumber
{
    mpz_t result_mpz;
    mpz_t this_mpz;
    mpz_t other_mpz;
    
    mpz_init(result_mpz);
    [self.mpzVal getValue:&this_mpz];
    [anotherNumber.mpzVal getValue:&other_mpz];
    
    mpz_sub(result_mpz, this_mpz, other_mpz);    
    return [BigInteger bigIntegerWithMPZ:result_mpz];
}

- (BigInteger *)multiply:(BigInteger *)anotherNumber
{
    mpz_t result_mpz;
    mpz_t this_mpz;
    mpz_t other_mpz;
    mpz_init(result_mpz);
    [self.mpzVal getValue:&this_mpz];
    [anotherNumber.mpzVal getValue:&other_mpz];
    
    mpz_mul(result_mpz, this_mpz, other_mpz);    
    return [BigInteger bigIntegerWithMPZ:result_mpz];
}

- (BigInteger *)divide:(BigInteger *)divisor
{
    mpz_t result_mpz;
    mpz_t this_mpz;
    mpz_t other_mpz;
    
    mpz_init(result_mpz);
    [self.mpzVal getValue:&this_mpz];
    [divisor.mpzVal getValue:&other_mpz];
    
    mpz_div(result_mpz, this_mpz, other_mpz);
    return [BigInteger bigIntegerWithMPZ:result_mpz];
}




@end
