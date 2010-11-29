//
//  CacaoVector.m
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CacaoVector.h"


@implementation CacaoVector

@synthesize elements;

+ (CacaoVector *)vectorWithArray:(NSArray *)theElements
{
    CacaoVector * vector = [[CacaoVector alloc] init];
    [vector setElements:theElements];
    
    return [vector autorelease];
}

- (NSString *)printable
{
    NSMutableString * printableElements = [NSMutableString string];
    for (id e in [self elements])    
        [printableElements appendFormat:@"%@ ", [e printable]];     
    return [NSString stringWithFormat:@"[%@]", [printableElements substringToIndex:(printableElements.length - 1)]];
}

- (NSUInteger)count
{
    return [[self elements] count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [[self elements] objectAtIndex:index];
}

@end
