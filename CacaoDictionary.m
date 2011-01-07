//
//  CacaoDictionary.m
//  Cacao
//
//  Created by Joubert Nel on 1/7/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import "CacaoDictionary.h"


@implementation CacaoDictionary

@synthesize elements;

+ (CacaoDictionary *)dictionaryWithNSDictionary:(NSDictionary *)theElements
{
    CacaoDictionary * dict = [[CacaoDictionary alloc] init];
    [dict setElements:theElements];
    return [dict autorelease];
}

- (NSString *)printable
{
    __block NSMutableString * kvPairs = [NSMutableString string];
    [self.elements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [kvPairs appendFormat:@"%@ %@ ", key, obj];
    }];
    
    return [NSString stringWithFormat:@"{%@}", kvPairs];
}

@end
