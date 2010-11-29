//
//  NSNumber+Printable.m
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "NSNumber+CacaoPrintable.h"


@implementation NSNumber (CacaoPrintable)


- (NSString *)printable;
{    
    if (CFGetTypeID(self) == CFBooleanGetTypeID())
    {
        return ([self boolValue] == YES) ? @"YES" : @"NO";
            
    }
    else return [self stringValue];
}

@end
