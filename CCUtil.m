//
//  CCUtil.m
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CCUtil.h"


@implementation CCUtil

+ (bool)is:(NSObject *)o1 equivalentTo:(NSObject *)o2
{
    if (o1 == o2)
        return YES;
    if (o1 != nil)
    {
        if ([o1 isKindOfClass:[NSNumber class]] && [o1 isKindOfClass:[NSNumber class]])
            return [o1 doubleValue] == [o2 doubleValue];
        else if ([o1 conformsToProtocol:CCPersistentCollection] || [o2 conformsToProtocol:CCPersistentCollection])
            return [CCUtil isPersistentCollection:o1 equivalentTo:o2];
        return [o1 isEqual:o2];
    }
    return NO;
}

+ (bool)isPersistentCollection:(id <CCPersistentCollection>)o1 equivalentTo:(id <CCPersistentCollection>)o2
{
}

@end
