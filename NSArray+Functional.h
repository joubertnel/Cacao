//
//  NSArray+Functional.h
//  Cacao
//
//  Created by Joubert Nel on 11/13/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray (Functional)


- (NSArray *)map:(id (^)(id object))block;
- (NSArray *)popFirstInto:(NSObject **)firstItem;

@end
