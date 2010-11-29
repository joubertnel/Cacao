//
//  NSObject+Printable.h
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (CacaoPrintable)

- (NSString *)printableWithIndentation:(int)indent;


@end
