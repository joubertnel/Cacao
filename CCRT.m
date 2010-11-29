//
//  CCRT.m
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CCRT.h"


@implementation CCRT


+ (NSArray *)arrayFromSeq:(id <CCSeqProtocol>)theSeq
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[CCRT length:theSeq]];
    while (theSeq = [theSeq next]) {
        [ret addObject:[theSeq first]];
    }
}


+ (int)length:(id <CCSeqProtocol>)theSeq
{
    int i = 0;
    for (id c = theSeq; c != nil; c = [c next])
        i++;
    return i;
}

@end
