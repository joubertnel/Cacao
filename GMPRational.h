//
//  GMPRational.h
//  Scream
//
//  Created by Joubert Nel on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "gmp.h"


@interface GMPRational : NSNumber {
	mpq_t	theNumber;
	int		base;
}

+ (id)rationalWithValue:(NSString *)theValue;
+ (id)rationalWithValue:(NSString *)theValue base:(int)theBase;

- (NSString *)stringValue;
- (NSString *)stringValueInBase:(int)base;

- (id)init:(NSString *)theValue base:(int)theBase;
- (id)init:(NSString *)theValue;
- (id)init;


@end
