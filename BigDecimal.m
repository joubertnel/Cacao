//
//  BigDecimal.m
//  Scream
//
//  Created by Joubert Nel on 3/17/09.
//  Copyright 2009 Joubert Nel. All rights reserved.
//

#import "BigDecimal.h"


@implementation BigDecimal

#pragma mark Set

- (void)setValue:(NSString *)theValue
{
	NSData *valueData = [NSData dataWithBytes:[theValue cStringUsingEncoding:NSUTF8StringEncoding]
									   length:[theValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	mpf_set_str (theNumber, [valueData bytes], 10);
}


#pragma mark Conversion

- (NSString *)stringValue
{
	return [self stringValueInBase:base digits:0]; // digits = 0 returns with max accuracy
}

- (NSString *)stringValueInBase:(int)theBase digits:(int)numberOfDigits
{
	mp_exp_t theExponent;
	NSString *asString = [NSString stringWithCString:mpf_get_str (NULL, &theExponent, theBase, numberOfDigits, theNumber)
                                            encoding:NSUTF8StringEncoding];
	return [asString stringByAppendingFormat:@"e%d", (int)theExponent];
}

#pragma mark Lifetime management

+ (id)bigDecimalWithValue:(NSString *)theValue
{
	return [BigDecimal bigDecimalWithValue:theValue base:10];
}

+ (id)bigDecimalWithValue:(NSString *)theValue base:(int)theBase
{
	return [[BigDecimal alloc] init:theValue base:theBase];
}

- (id)init:(NSString *)theValue base:(int)theBase
{
	[super init];
	NSData *valueData = [NSData dataWithBytes:[theValue cStringUsingEncoding:NSUTF8StringEncoding]
									   length:[theValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	mpf_init_set_str (theNumber, [valueData bytes], theBase);
	base = theBase;

	return self;
}

- (id)init:(NSString *)theValue
{
	return [self init:theValue base:10];
}


- (id)init
{
	return [self init:0];
}

- (void)dealloc
{
	mpf_clear (theNumber);
	[super dealloc];
}

@end
