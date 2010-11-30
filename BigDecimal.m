//
//  BigDecimal.m
//  Scream
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
