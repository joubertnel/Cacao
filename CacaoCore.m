//
//  CacaoCore.m
//  Cacao
//
//    Copyright 2010, 2011, Joubert Nel. All rights reserved.
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

#import "CacaoArgumentName.h"
#import "CacaoCore.h"
#import "CacaoDictionary.h"
#import "CacaoFn.h"
#import "CacaoSymbol.h"
#import "BigInteger.h"
#import "NSArray+Functional.h"

static NSString * GLOBAL_NAMESPACE = @"cacao";
static NSString * SYMBOL_NAME_YES = @"YES";
static NSString * SYMBOL_NAME_NO = @"NO";

@implementation CacaoCore

+ (NSDictionary *)functions
{
    CacaoSymbol * yesSymbol = [CacaoSymbol symbolWithName:SYMBOL_NAME_YES inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * noSymbol = [CacaoSymbol symbolWithName:SYMBOL_NAME_NO inNamespace:GLOBAL_NAMESPACE];
    
    CacaoSymbol * sumOpSymbol = [CacaoSymbol symbolWithName:@"+" inNamespace:GLOBAL_NAMESPACE];
    NSString * sumArgName = @"numbers";
    CacaoSymbol * sumArgSym = [CacaoSymbol symbolWithName:sumArgName inNamespace:nil];
    CacaoFn * sumFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        BigInteger * sum = [BigInteger bigIntegerWithValue:@"0"];
        CacaoVector * numbers = [argsAndVals objectForKey:sumArgSym];
        for (BigInteger * number in numbers.elements)
            sum = [sum add:number];
        return sum;
    } restArg:sumArgSym];
    
    CacaoSymbol * subtractOpSymbol = [CacaoSymbol symbolWithName:@"-" inNamespace:GLOBAL_NAMESPACE];
    NSString * subArgName = @"numbers";
    CacaoSymbol * subArgSym = [CacaoSymbol symbolWithName:subArgName inNamespace:nil];
    CacaoFn * subtractFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * numbers = [argsAndVals objectForKey:subArgSym];
        BigInteger * answer = [numbers.elements objectAtIndex:0];
        NSUInteger numberCount = numbers.count;
        for (NSUInteger i=1; i < numberCount; i++) {
            BigInteger * num = [numbers.elements objectAtIndex:i];
            answer = [answer subtract:num];
        }
        return answer;        
    } restArg:subArgSym];
    
    CacaoSymbol * multiplyOpSymbol = [CacaoSymbol symbolWithName:@"*" inNamespace:GLOBAL_NAMESPACE];
    NSString * multiplyArgName = @"numbers";
    CacaoSymbol * multiplyArgSym = [CacaoSymbol symbolWithName:multiplyArgName inNamespace:nil];
    CacaoFn * multiplyFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {        
        BigInteger * answer = [BigInteger bigIntegerWithValue:@"1"];
        CacaoVector * numbers = [argsAndVals objectForKey:multiplyArgSym];
        for (BigInteger * number in numbers.elements)
            answer = [answer multiply:number];
        return answer;
    } restArg:multiplyArgSym];    
    
    CacaoSymbol * divideOpSym = [CacaoSymbol symbolWithName:@"/" inNamespace:GLOBAL_NAMESPACE];
    NSString * divideArgName = @"numbers";
    CacaoSymbol * divideArgSym = [CacaoSymbol symbolWithName:divideArgName inNamespace:nil];
    CacaoFn * divideFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        BigInteger * firstNumber;
        CacaoVector * numbers = [argsAndVals objectForKey:divideArgSym];        
        NSArray * remainingNumbers = [[numbers elements] popFirstInto:&firstNumber];
        BigInteger * answer = firstNumber;
        for (BigInteger * number in remainingNumbers)
            answer = [answer divide:number];
        return answer;
    } restArg:divideArgSym];    
    
    
    CacaoSymbol * lessThanSymbol = [CacaoSymbol symbolWithName:@"<" inNamespace:GLOBAL_NAMESPACE];
    NSString * lessThanArgName = @"numbers";
    CacaoSymbol * lessThanArgSym = [CacaoSymbol symbolWithName:lessThanArgName inNamespace:nil];
    CacaoFn * lessThanFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * numbers = [argsAndVals objectForKey:lessThanArgSym];
        BigInteger * num1 = [numbers objectAtIndex:0];
        BigInteger * num2 = [numbers objectAtIndex:1];
        BOOL isLessThan = [num1 isLessThan:num2];
        if (isLessThan)
            return [NSNumber numberWithBool:YES];
        else 
            return [NSNumber numberWithBool:NO];

    } restArg:lessThanArgSym];
    
    CacaoSymbol * rangeSymbol = [CacaoSymbol symbolWithName:@"range" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * rangeStartArgSym = [CacaoSymbol symbolWithName:@"start" inNamespace:nil];
    CacaoSymbol * rangeEndArgSym = [CacaoSymbol symbolWithName:@"end" inNamespace:nil];
    CacaoVector * rangeArgs = [CacaoVector vectorWithArray:[NSArray arrayWithObjects: rangeStartArgSym, rangeEndArgSym, nil]];
    CacaoFn * rangeFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        BigInteger * startNum = [argsAndVals objectForKey:rangeStartArgSym];
        BigInteger * endNum = [argsAndVals objectForKey:rangeEndArgSym];
        BigInteger * i = startNum;
        NSMutableArray * numbers = [NSMutableArray array];
        while ([i isLessThan:endNum]) {
            [numbers addObject:i];
            i = [i add:[BigInteger bigIntegerWithValue:@"1"]];
        }
        return [CacaoVector vectorWithArray:numbers];
    } args:rangeArgs restArg:nil];
    
    
    CacaoSymbol * mapSymbol = [CacaoSymbol symbolWithName:@"map" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * mapFnArgSym = [CacaoSymbol symbolWithName:@"fn" inNamespace:nil];
    CacaoSymbol * mapSeqArgSym = [CacaoSymbol symbolWithName:@"vec" inNamespace:nil];
    CacaoVector * mapArgs = [CacaoVector vectorWithArray:[NSArray arrayWithObjects:mapFnArgSym, mapSeqArgSym, nil]]; 
    
    CacaoFn * pmapFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        id seq = [argsAndVals objectForKey:mapSeqArgSym];

        CacaoFn * fn = [argsAndVals objectForKey:mapFnArgSym];
        NSString * fnArgNameString = [fn.argNames anyObject];
        CacaoArgumentName * fnArgName = [CacaoArgumentName argumentNameInternedFromSymbol:[CacaoSymbol symbolWithName:fnArgNameString inNamespace:nil]];
        
        __block NSMutableArray * resultArray = [NSMutableArray arrayWithCapacity:[[seq elements] count]];
 
        [[seq elements] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            id r = [fn invokeWithArgsAndVals:[NSArray arrayWithObjects:fnArgName, obj, nil]];            
            [resultArray insertObject:r atIndex:idx];                       

        }];

        return [CacaoVector vectorWithArray:resultArray];        

    } args:mapArgs restArg:nil];
        
    

      
    NSDictionary * globalMappings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], yesSymbol,
                                     [NSNumber numberWithBool:NO], noSymbol,
                                     sumFn, sumOpSymbol, 
                                     subtractFn, subtractOpSymbol,
                                     multiplyFn, multiplyOpSymbol,
                                     lessThanFn, lessThanSymbol,
                                     rangeFn, rangeSymbol,
                                     pmapFn, mapSymbol,
                                     divideFn, divideOpSym,
                                     nil];
    return globalMappings;
    return nil;
}


@end
