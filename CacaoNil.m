//
//  CacaoNil.m
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CacaoNil.h"


@implementation CacaoNil

+ (CacaoNil *)nilObject
{
    return [[[CacaoNil alloc] init] autorelease];
}

- (NSString *)printable
{
    return @"nil";
}

@end
