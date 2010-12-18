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

#pragma mark Lifetime management

+ (id)bigIntegerWithValue:(NSString *)theValue
{
	return [BigInteger bigIntegerWithValue:theValue base:10];
}

+ (id)bigIntegerWithValue:(NSString *)theValue base:(int)theBase
{
    BigInteger * bigInteger = [[BigInteger alloc] init:theValue base:theBase];
    return [bigInteger autorelease];
}


- (id)init:(NSString *)theValue base:(int)theBase
{
	[super init];
	NSData *valueData = [NSData dataWithBytes:[theValue cStringUsingEncoding:NSUTF8StringEncoding]
									   length:[theValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	
	mpz_init_set_str (theNumber, [valueData bytes], theBase);
	base = theBase; // remember the base so that when the stringValue method is called, we can use this by default
	
	return self;	
}

- (id)init:(NSString *)theValue
{	
	return [self init:theValue base:10];
}


- (id)init
{
	[super init];
	mpz_init (theNumber);
	return self;
}

- (id)initWithGMPInteger:(mpz_t)theGMPInteger
{
	[self init];
	mpz_set (theNumber, theGMPInteger);
	return self;
}

- (id)negate
{
	mpz_t tempNegatedGMPInteger;
	mpz_init (tempNegatedGMPInteger);
	mpz_neg (tempNegatedGMPInteger, theNumber);
	BigInteger *negatedBigInteger = [[BigInteger alloc] initWithGMPInteger:tempNegatedGMPInteger];
	mpz_clear (tempNegatedGMPInteger);
	return [negatedBigInteger autorelease];
}

- (void)dealloc
{
	mpz_clear (theNumber);
	[super dealloc];
}


#pragma mark Set

- (void)setValue:(NSString *)theValue
{
	NSData *valueData = [NSData dataWithBytes:[theValue cStringUsingEncoding:NSUTF8StringEncoding]
									   length:[theValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	
	mpz_set_str (theNumber, [valueData bytes], 10);	
}

#pragma mark Conversion


- (double)doubleValue
{
	return mpz_get_d (theNumber);
}

- (unsigned long)unsignedLongValue
{
	return mpz_get_ui (theNumber);
}

- (int)intValue
{
	return mpz_get_si (theNumber);
}

- (NSString *)stringValue
{
    NSString * valueAsString = [[NSString alloc] initWithCString:mpz_get_str (NULL, base, theNumber)];
    return [valueAsString autorelease];
}

#pragma mark Comparison

- (int)compareGMP:(mpz_t)aGMPBigInteger
{
	return mpz_cmp (theNumber, aGMPBigInteger);
}

- (NSComparisonResult)compare:(BigInteger *)otherBigInteger
{
	int compareResult = [otherBigInteger compareGMP:theNumber];
	
	if (compareResult > 0)
		return NSOrderedDescending; // the otherBigInteger is larger, so this is smaller
	else if (compareResult < 0)
		return NSOrderedAscending; // the otherBigInteger is smaller, so this is larger
	else return NSOrderedSame;
		
}




@end
