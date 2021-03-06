//
//  TestDictionaries.m
//  Cacao
//
//    Copyright 2011, Joubert Nel. All rights reserved.
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
//    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT L(IABILITY, OR TORT (INCLUDING
//    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//    The views and conclusions contained in the software and documentation are those of the
//    authors and should not be interpreted as representing official policies, either expressed
//    or implied, of Joubert Nel.

#import "TestSequences.h"


@implementation TestSequences

- (void)testKeyAsFunction
{
    TEST_TRUE(@"(= \"Frederic\" (:first {:first \"Frederic\" :last \"Chopin\"}))");
}

- (void)testKeys
{
}

- (void)testVals
{
}

- (void)contains
{
    TEST_TRUE(@"(contains? item:34 vec:(vals dict:{:first \"Frederic\" :age 34}))");
    TEST_TRUE(@"(contains? item::first vec:(keys dict:{:first \"Frederic\" :last \"Chopin\"}))");
}

- (void)testLazyVectors
{
    TEST_FALSE(@"(= (range start:1 end:50) (range start:1 end:40000000000000000))");
    TEST_TRUE(@"(= (range start:1 end:100) (range start:1 end:100))");
    TEST_TRUE(@"(= (range start:5 end:80) (range start:5 end:80))");
    TEST_FALSE(@"(= (range start:5 end:800) (range start:3 end:40))");
    TEST_TRUE(@"(= 99 (get i:95 vec:(range start:4 end:100)))");
    TEST_TRUE(@"(= 1 (let [r (range start:1 end:10) c (count vec:r)] (get i:0 vec:r|");
    TEST_TRUE(@"(= 2 (let [r (range start:1 end:10) c (count vec:r)] (get i:1 vec:r|");
}

- (void)testHigherOrderFunctionsOnLazyVectors
{
    TEST_TRUE(@"(= 100020001 (get i:10000 vec:(map fn:(fn [n] (* n n)) vec:(range start:1 end:10000000))))");
    TEST_TRUE(@"(= 10 (get i:9 vec:(let [r (range start:1 end:10000)] r (map fn:(fn [n] n) vec:r))))");
}



@end
