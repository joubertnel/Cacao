//
//  CCCons.m
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CCCons.h"


@implementation CCCons

@synthesize first;
@synthesize more;

- (CCCons *)initWithMeta:(id <CCPersistentMapProtocol>)theMeta first:(NSObject *)theFirst more:(id <CCSeqProtocol>)theMore
{
    if (self = [super initWithMeta:theMeta]) {
        [self setFirst:theFirst];
        [self setMore:theMore];
    }
    return self;
}

- (CCCons *)initWith:(NSObject *)theFirst more:(id <CCSeqProtocol>)theMore
{
    [self setFirst:theFirst];
    [self setMore:theMore];
    return self;
}

- (id <CCSeqProtocol>)next
{
    return self.more.seq;
}

- (int)count
{ 
    return 1;
}



@end
