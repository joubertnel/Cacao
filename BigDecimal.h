//
//  BigDecimal.h
//  Scream
//
//  Created by Joubert Nel on 3/17/09.
//  Copyright 2009 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "gmp.h"


@interface BigDecimal : NSNumber {
	mpf_t	theNumber;
	int		base;
}

+ (id)bigDecimalWithValue:(NSString *)theValue;
+ (id)bigDecimalWithValue:(NSString *)theValue base:(int)theBase;

- (void)setValue:(NSString *)theValue;

- (NSString *)stringValue;
- (NSString *)stringValueInBase:(int)theBase digits:(int)numberOfDigits;

- (id)init:(NSString *)theValue base:(int)theBase;
- (id)init:(NSString *)theValue;
- (id)init;

@end
