//
//  NSObject+Printable.m
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "NSObject+CacaoPrintable.h"


@implementation NSObject (CacaoPrintable)

- (NSString *)printableWithIndentation:(int)indent
{        
    NSMutableString * _printable = [NSMutableString string];    
    
    if ([self respondsToSelector:@selector(printable)])
    {
        NSMutableString * _textualRepresentation = [NSMutableString stringWithString:[self performSelector:@selector(printable)]];
        for (int i=0; i < indent; i++)
        {
            [_printable appendString:@" "];
        }
        [_printable appendString:_textualRepresentation];        
    }
    
    return _printable;
}

@end
