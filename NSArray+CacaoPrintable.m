//
//  NSArray+Printable.m
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "NSArray+CacaoPrintable.h"

int const CACAO_PRINTABLE_INDENTATION = 2;

@implementation NSArray (CacaoPrintable)


- (NSString *)printableTreeComponent:(id)treeComponent indented:(int)indent
{
    return [treeComponent printableWithIndentation:(indent + CACAO_PRINTABLE_INDENTATION)];
}

- (NSString *)printableWithIndentation:(int)indent
{
    NSMutableString * printable = [NSMutableString string];
    for (id component in self)
    {
        NSString * printableComponent = [self printableTreeComponent:component indented:indent];        
        [printable appendString:printableComponent];
        [printable appendString:@"\n"];
    }
    
    return printable;
}

@end
