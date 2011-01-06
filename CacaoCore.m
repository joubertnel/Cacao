//
//  CacaoCore.m
//  Cacao
//
//  Created by Joubert Nel on 12/25/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CacaoArgumentName.h"
#import "CacaoCore.h"
#import "CacaoSymbol.h"
#import "CacaoFn.h"
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
        __block NSMutableArray * results = [NSMutableArray arrayWithCapacity:[[seq elements] count]];
        [[seq elements] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id r = [fn invokeWithArgsAndVals:[NSArray arrayWithObjects:fnArgName, obj, nil]];
            [results insertObject:r atIndex:idx];            
        }];
        return [CacaoVector vectorWithArray:results];        
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
