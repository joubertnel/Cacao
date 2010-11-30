//
//  CacaoFn.m
//  Cacao
//
//  Created by Joubert Nel on 11/22/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CacaoFn.h"


@implementation CacaoFn

@synthesize func;

+ (CacaoFn *)fnWithDispatchFunction:(DispatchFunction)theFunc;
{
    CacaoFn * fn = [[CacaoFn alloc] init];
    [fn setFunc:theFunc];
    return [fn autorelease];
}

- (id)invokeWithParams:(NSArray *)theParams
{
    return func(theParams);
}

@end
