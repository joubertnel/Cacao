//
//  MathFunctionMakers.m
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
//    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//    The views and conclusions contained in the software and documentation are those of the
//    authors and should not be interpreted as representing official policies, either expressed
//    or implied, of Joubert Nel.

#import "CacaoMathFunctionMakers.h"
#import "BigInteger.h"
#import "NSArray+Functional.h"

@implementation CacaoMathFunctionMakers


+ (NSString *)namespace
{
    return GLOBAL_NAMESPACE;
}


#pragma mark Implementation of math functions in Cacao

+ (NSDictionary *)sum
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"+" inNamespace:GLOBAL_NAMESPACE];
    NSString * argName = @"numbers";
    CacaoSymbol * argSym = [CacaoSymbol symbolWithName:argName inNamespace:nil];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        BigInteger * sum = [BigInteger bigIntegerWithValue:@"0"];
        CacaoVector * numbers = [argsAndVals objectForKey:argSym];
        for (BigInteger * number in numbers.elements)
            sum = [sum add:number];
        return sum;
    } restArg:argSym];   
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}

+ (NSDictionary *)subtract
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"-" inNamespace:GLOBAL_NAMESPACE];
    NSString * argName = @"numbers";
    CacaoSymbol * argSym = [CacaoSymbol symbolWithName:argName inNamespace:nil];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * numbers = [argsAndVals objectForKey:argSym];
        BigInteger * answer = [numbers.elements objectAtIndex:0];
        NSUInteger numberCount = numbers.count;
        for (NSUInteger i=1; i < numberCount; i++) {
            BigInteger * num = [numbers.elements objectAtIndex:i];
            answer = [answer subtract:num];
        }
        return answer;        
    } restArg:argSym];
    
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}

+ (NSDictionary *)multiply
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"*" inNamespace:GLOBAL_NAMESPACE];
    NSString * argName = @"numbers";
    CacaoSymbol * argSym = [CacaoSymbol symbolWithName:argName inNamespace:nil];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {        
        BigInteger * answer = [BigInteger bigIntegerWithValue:@"1"];
        CacaoVector * numbers = [argsAndVals objectForKey:argSym];
        for (BigInteger * number in numbers.elements)
            answer = [answer multiply:number];
        return answer;
    } restArg:argSym]; 
    
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}

+ (NSDictionary *)divide
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"/" inNamespace:GLOBAL_NAMESPACE];
    NSString * argName = @"numbers";
    CacaoSymbol * argSym = [CacaoSymbol symbolWithName:argName inNamespace:nil];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        BigInteger * firstNumber;
        CacaoVector * numbers = [argsAndVals objectForKey:argSym];        
        NSArray * remainingNumbers = [[numbers elements] popFirstInto:&firstNumber];
        BigInteger * answer = firstNumber;
        for (BigInteger * number in remainingNumbers)
            answer = [answer divide:number];
        return answer;
    } restArg:argSym];   
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}



@end
