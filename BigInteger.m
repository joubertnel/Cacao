//
//  BigInteger.m
//  Scream
//
//  Created by Joubert Nel on 3/16/09.
//  Copyright 2009 Joubert Nel. All rights reserved.
//

#import "BigInteger.h"


@implementation BigInteger

#pragma mark Lifetime management

+ (id)bigIntegerWithValue:(NSString *)theValue
{
	return [BigInteger bigIntegerWithValue:theValue base:10];
}

+ (id)bigIntegerWithValue:(NSString *)theValue base:(int)theBase
{
	return [[BigInteger alloc] init:theValue base:theBase];
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
	return negatedBigInteger;
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
	return [[NSString alloc] initWithCString:mpz_get_str (NULL, base, theNumber)];
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
