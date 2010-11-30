//
//  TestMath.m
//  Cacao
//
//  Created by Joubert Nel on 11/27/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "TestMath.h"


@implementation TestMath

- (void)setUp
{
    env = [CacaoEnvironment globalEnvironment];
}

- (void)tearDown
{
    [env release];
}

- (void)testIntegerEquality
{
    CacaoAST * ast = [CacaoAST astWithText:@"(= 5 5)"];
    NSNumber * result = (NSNumber *)[CacaoEnvironment eval:ast.tree inEnvironment:env];
    STAssertTrue([result boolValue], nil);
}

- (void)testIntegerInequality
{
    CacaoAST * ast = [CacaoAST astWithText:@"(= 5 123)"];
    NSNumber * result = (NSNumber *)[CacaoEnvironment eval:ast.tree inEnvironment:env];
    STAssertFalse([result boolValue], nil);
}

- (void)testIntegerAddition
{   
    CacaoAST * ast = [CacaoAST astWithText:@"(= 7 (+ 4 3))"];
    NSNumber * result = (NSNumber *)[CacaoEnvironment eval:ast.tree inEnvironment:env];
    STAssertTrue([result boolValue], nil);
}

- (void)testIntegerSubtraction
{
    CacaoAST * ast = [CacaoAST astWithText:@"(= 8 (- 20 12))"];
    NSNumber * result = (NSNumber *)[CacaoEnvironment eval:ast.tree inEnvironment:env];
    STAssertTrue([result boolValue], nil);
}

- (void)testIntegerMultiplication
{
    CacaoAST * ast = [CacaoAST astWithText:@"(= 999 (* 3 333))"];
    NSNumber * result = (NSNumber *)[CacaoEnvironment eval:ast.tree inEnvironment:env];
    STAssertTrue([result boolValue], nil);
}

- (void)testIntegerDivision
{
    CacaoAST * ast = [CacaoAST astWithText:@"(= 10 (/ 20 2))"];
    NSNumber * result = (NSNumber *)[CacaoEnvironment eval:ast.tree inEnvironment:env];
    STAssertTrue([result boolValue], nil);
}


@end
