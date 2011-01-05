//
//  TestCore.m
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


#import "TestCore.h"
#import "BigInteger.h"
#import "CacaoVector.h"


@implementation TestCore

- (void)testFnBasic
{
    NSString * test = @"(let [echo (fn [text] text)] (echo text:\"test\"|";
    NSString * result = (NSString *)[CacaoEnvironment evalText:test inEnvironment:env];
    STAssertTrue([result isEqualToString:@"test"], nil);    
}

- (void)testNestedFn
{
    NSString * test = @"(= \"birdy\" (let [func1 (fn[n] n) func2 (fn[m] (func1 n:m))] (func2 m:\"birdy\")))";
    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
    STAssertTrue([result boolValue], nil);
}

- (void)testMultipleArgs
{
    NSString * expression = @"(let [echo (fn [x y] x)] (echo x:\"first\" y:\"second\"|";
    NSString * result = (NSString *)[CacaoEnvironment evalText:expression inEnvironment:env];
    STAssertTrue([result isEqual:@"first"], nil);
}

- (void)testInsufficientArgs
{
    NSString * expression = @"(let [echo (fn [x y] x)] (echo x:\"first\"|";
    STAssertThrowsSpecificNamed([CacaoEnvironment evalText:expression inEnvironment:env],
                                NSException,
                                @"Incorrect CacaoFn invocation", nil);
}

- (void)testRestArgs
{
    
}

- (void)testRangeFn
{
    NSString * expression = @"(range start:4 end:100)";
    CacaoVector * result = (CacaoVector *)[CacaoEnvironment evalText:expression inEnvironment:env];
    BigInteger * first = (BigInteger *)[result objectAtIndex:0];
    BigInteger * last = (BigInteger *)[result.elements lastObject];
    STAssertTrue([first isEqual:[BigInteger bigIntegerWithValue:@"4"]], nil);
    STAssertTrue([last isEqual:[BigInteger bigIntegerWithValue:@"99"]], nil);
}

- (void)testQuote
{
    NSString * expression;
    NSObject * result;
    BOOL isResultOfCorrectClass;
    
    expression = @"(= 4 '4)";
    result = (NSNumber *)[CacaoEnvironment evalText:expression inEnvironment:env];
    STAssertTrue([(NSNumber *)result boolValue], nil);
    
    expression = @"'unevaluatedSymbol";
    result = [CacaoEnvironment evalText:expression inEnvironment:env];
    isResultOfCorrectClass = [result isKindOfClass:[CacaoSymbol class]];
    STAssertTrue(isResultOfCorrectClass, nil);
    
    expression = @"'[3 4 more]";
    result = [CacaoEnvironment evalText:expression inEnvironment:env];
    isResultOfCorrectClass = [result isKindOfClass:[CacaoVector class]];
    STAssertTrue(isResultOfCorrectClass, nil);    
}

@end
