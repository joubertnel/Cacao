//
//  NSArray+Functional.m
//  Cacao
//
//  Created by Joubert Nel on 11/13/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "NSArray+Functional.h"


@implementation NSArray (Functional)

- (NSArray *)map:(id (^)(id object))block 
{
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj)];
    }];
    
    return [NSArray arrayWithArray:result];
}

- (NSArray *)popFirstInto:(NSObject **)firstItem
{
    NSObject * firstObject = [self objectAtIndex:0];
    *firstItem = firstObject;
    NSRange rest;
    rest.location = 1;
    rest.length = [self count] - 1;
    return [self subarrayWithRange:rest];
}

@end
