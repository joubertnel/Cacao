//
//  TestPlatformIntegration.m
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

#import "TestPlatformIntegration.h"


@implementation TestPlatformIntegration

// Not sure yet whether I want to support this kind of stuff, the way Clojure does for Java interop. 

//- (void)testMethodThatReturnsLongLong
//{
//    NSString * test = @"(.length \"distribution\")";
//    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
//    STAssertEquals([result longLongValue], 12LL, nil, nil);
//}
//
//- (void)testMethodThatReturnsLong
//{
//    NSString * test = @"(= 123 (.integerValue \"123\"))";
//    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
//    STAssertTrue([result boolValue], nil);
//}
//
//- (void)testMethodThatReturnsDouble
//{
//    NSString * test = @"(= 3.4 (.doubleValue \"3.4\"))";
//    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
//    STAssertTrue([result boolValue], nil);
//}
//
//- (void)testMethodThatReturnsFloat
//{
//    NSString * test = @"(= (.floatValue \"2.23\") (.floatValue \"2.23\"))";
//    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
//    STAssertTrue([result boolValue], nil);
//}
//
//- (void)testMethodThatReturnsCharAndTakesOneNumberArg
//{
//    NSString * test = @"(= \"l\" (.characterAtIndex: \"voila\" 3))";
//    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
//    STAssertTrue([result boolValue], nil);
//}
//
//- (void)testMethodThatTakesOneStringArg
//{
//    NSString * test = @"(= \"hello_there\" (.stringByAppendingString: \"hello\" \"_there\"))";
//    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
//    STAssertTrue([result boolValue], nil);
//}
//
//- (void)testSimpleInstancingAndMethodCall
//{
//    NSString * test = @"(= 5 (.length (NSString/stringWithString: \"hello\")))";
//    NSNumber * result = (NSNumber *)[CacaoEnvironment evalText:test inEnvironment:env];
//    STAssertTrue([result boolValue], nil);
//}

@end
