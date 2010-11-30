//
//  GMPRational.m
//  Scream
//
//  Created by Joubert Nel on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GMPRational.h"


@implementation GMPRational

+ (id)rationalWithValue:(NSString *)theValue
{
	return [GMPRational rationalWithValue:theValue base:10];
}

+ (id)rationalWithValue:(NSString *)theValue base:(int)theBase
{
	return [[GMPRational alloc] init:theValue base:theBase];
}

#pragma mark Conversion

- (NSString *)stringValue
{
	return [self stringValueInBase:base];
}

- (NSString *)stringValueInBase:(int)theBase
{
	return [NSString stringWithCString:mpq_get_str (NULL, theBase, theNumber) encoding:NSUTF8StringEncoding];
}

#pragma mark Lifetime management

- (id)init
{
	return [self init:@"0"];
}

- (id)init:(NSString *)theValue
{
	return [self init:theValue base:10];
}

- (id)init:(NSString *)theValue base:(int)theBase
{
	[super init];
	mpq_init (theNumber);
	NSData *valueData = [NSData dataWithBytes:[theValue cStringUsingEncoding:NSUTF8StringEncoding]
									   length:[theValue lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	mpq_set_str (theNumber, [valueData bytes], theBase);
	base = theBase; // remember so that we can use as default for conversion
	return self;
}

@end
