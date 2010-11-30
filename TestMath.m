//
//  TestMath.m
//  Cacao
//
//    Copyright 2010, Joubert Nel. All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification, are
//    permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other materials
//    provided with the distribution.
//
//    THIS SOFTWARE IS PROVIDED BY JOUBERT NEL "AS IS'' AND ANY EXPRESS OR IMPLIED
//    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOUBERT NEL OR
//    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//    The views and conclusions contained in the software and documentation are those of the
//    authors and should not be interpreted as representing official policies, either expressed
//    or implied, of Joubert Nel.

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
