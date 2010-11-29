//
//  CCSeq.m
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CCSeq.h"


@implementation CCSeq


- (int)count 
{
    int i = 1;
    for (id <CCSeqProtocol> s = [self next]; s != nil; s = [s next], i++)
        if ([s isKindOfClass:[CCCounted class]])
            return i + [s count];
    return i;
}

- (id <CCSeqProtocol>)seq
{
    return self;
}

- (id <CCSeqProtocol>)cons:(NSObject *)theObject
{
    return [[CCCons alloc] initWith:theObject more:self];
}

- (id <CCSeqProtocol>)more
{
    return [self next];
}

- (NSArray *)toArray
{
    return [CCRT arrayFromSeq:self];
    
}

- (bool)containsAll:(NSArray *)theObjects
{
    for (id o in theObjects)
    {
        if (![self contains:o])
            return NO;
    }
    return YES;
}

- (int)size
{
    return [self count];
}

- (bool)isEmpty
{
    return self == nil;
}

- (bool)contains:(NSObject *)theObject
{
    for (id s = self; s != nil; s = [s next])
        if ([CCUtil is:[s first] equivalentTo:theObject]) {
            return YES;
        }
    return NO;
}


#pragma mark List messages

- (NSArray *)reify
{
    return 
}

@end
