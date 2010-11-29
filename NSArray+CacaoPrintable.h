//
//  NSArray+Printable.h
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern int const CACAO_PRINTABLE_INDENTATION;

@interface NSArray (CacaoPrintable)

- (NSString *)printableWithIndentation:(int)indent;

@end
