//
//  CacaoAST.h
//  Cacao
//
//  Created by Joubert Nel on 11/13/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CacaoSymbol.h"
#import "NSArray+Functional.h"
#import "NSArray+CacaoPrintable.h"
#import "CacaoNil.h"
#import "CacaoNilNotCallableException.h"
#import "CacaoVector.h"

@interface CacaoAST : NSObject {
    NSString *source;
    NSArray *tokens;
    NSArray *tree;

}

@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSArray *tokens;
@property (nonatomic, retain) NSArray *tree;

- (void)tokenize;
- (void)parse;
- (CacaoAST *)initWithText:(NSString *)theText;
- (void)explore;
- (NSString *)toString;


@end
