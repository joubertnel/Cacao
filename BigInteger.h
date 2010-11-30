//
//  BigInteger.h
//  Scream
//
//  Created by Joubert Nel on 3/16/09.
//  Copyright 2009 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "gmp.h"


typedef enum {
	SMALLER=-1, 
	EQUAL=0, 
	LARGER=1
} BigIntegerComparison;




@interface BigInteger : NSNumber {
	mpz_t	theNumber;
	int		base;
}

+ (id)bigIntegerWithValue:(NSString *)theValue;
+ (id)bigIntegerWithValue:(NSString *)theValue base:(int)theBase;


- (void)setValue:(NSString *)theValue;
- (NSComparisonResult)compare:(BigInteger *)otherBigInteger;

- (double)doubleValue;
- (int)intValue;
- (NSString *)stringValue;
- (unsigned long)unsignedLongValue;


- (id)init:(NSString *)theValue base:(int)theBase;
- (id)init:(NSString *)theValue;
- (id)init;
- (id)negate;

@end
