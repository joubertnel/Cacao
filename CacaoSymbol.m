//
//  CacaoSymbol.m
//  Cacao
//
//  Created by Joubert Nel on 11/13/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CacaoSymbol.h"


@implementation CacaoSymbol

@synthesize name;
@synthesize ns;

+ (CacaoSymbol *)symbolWithName:(NSString *)theName
{
    CacaoSymbol * symbol = [[CacaoSymbol alloc] init];
    [symbol setName:theName];
    return [symbol autorelease];
}

- (BOOL)isEqualToSymbol:(CacaoSymbol *)otherSymbol
{
    return [[self stringValue] isEqualToString:[otherSymbol stringValue]];
}

- (NSString *)stringValue
{
    return self.name;
}

- (NSString *)printable
{
    return [self stringValue];
}

- (id)copyWithZone:(NSZone *)zone
{
    CacaoSymbol * aCopy = [CacaoSymbol symbolWithName:[self name]];
    return [aCopy retain];
}


@end
