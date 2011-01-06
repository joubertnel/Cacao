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


#pragma mark Integers 

- (void)testIntegerEquality
{
    TEST_TRUE(@"(= 5 5)");
}

- (void)testBigIntegerEquality
{
    TEST_TRUE(@"(= 123456789123456789123456789123456789123456789123456789123456789123456789 123456789123456789123456789123456789123456789123456789123456789123456789)");
}

- (void)testIntegerInequality
{
    TEST_FALSE(@"(= 5 123)");
}

- (void)testIntegerLessThan
{
    TEST_TRUE(@"(< 123456789 1234567890)");
}

- (void)testBigIntegerInequality
{
    TEST_FALSE(@"(= 123456789123456789123456789123456789123456789123456789123456789123456789 938479)");
}

- (void)testIntegerAddition
{       
    TEST_TRUE(@"(= 7 (+ 4 3|");
}

- (void)testBigIntegerAddition
{
    TEST_TRUE(@"(= 2837506749332229293531724051021151478729667013 (+ 38475683465834768236487236478643758634758 2837468273648763458763487563784672834687263487 283768768))");
}

- (void)testZeroAddition
{
    TEST_TRUE(@"(= 0 (+ 0 0))");
}

- (void)testIntegerSubtraction
{    
    TEST_TRUE(@"(= 8 (- 20 12|");
}

- (void)testIntegerMultiplication
{
    TEST_TRUE(@"(= 999 (* 3 333|");
}

- (void)testIntegerDivision
{
    TEST_TRUE(@"(= 19 (/ 5681 299|");
}

- (void)testNegativeIntegers
{
    TEST_TRUE(@"(= -45 (- 50 95|");   
    TEST_TRUE(@"(= -5 (/ 10 -2))");
}





@end
