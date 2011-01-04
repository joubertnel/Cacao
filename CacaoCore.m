//
//  CacaoCore.m
//  Cacao
//
//  Created by Joubert Nel on 12/25/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CacaoCore.h"
#import "CacaoSymbol.h"
#import "CacaoFn.h"
#import "CacaoBigInteger.h"

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
        CacaoBigInteger * sum = [CacaoBigInteger bigIntegerFromText:@"0"];
        CacaoVector * numbers = [argsAndVals objectForKey:sumArgSym];
        for (CacaoBigInteger * number in numbers.elements)
            sum = [sum add:number];
        return sum;
    } params:nil restArg:sumArgSym];
    
    CacaoSymbol * subtractOpSymbol = [CacaoSymbol symbolWithName:@"-" inNamespace:GLOBAL_NAMESPACE];
    NSString * subArgName = @"numbers";
    CacaoSymbol * subArgSym = [CacaoSymbol symbolWithName:subArgName inNamespace:nil];
    CacaoFn * subtractFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * numbers = [argsAndVals objectForKey:subArgSym];
        CacaoBigInteger * answer = [numbers.elements objectAtIndex:0];
        NSUInteger numberCount = numbers.count;
        for (NSUInteger i=1; i < numberCount; i++) {
            CacaoBigInteger * num = [numbers.elements objectAtIndex:i];
            answer = [answer subtract:num];
        }
        return answer;        
    } params:nil restArg:subArgSym];
    
    CacaoSymbol * lessThanSymbol = [CacaoSymbol symbolWithName:@"<" inNamespace:GLOBAL_NAMESPACE];
    NSString * lessThanArgName = @"numbers";
    CacaoSymbol * lessThanArgSym = [CacaoSymbol symbolWithName:lessThanArgName inNamespace:nil];
    CacaoFn * lessThanFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * numbers = [argsAndVals objectForKey:lessThanArgSym];
        CacaoBigInteger * num1 = [numbers objectAtIndex:0];
        CacaoBigInteger * num2 = [numbers objectAtIndex:1];
        BOOL isLessThan = [num1 isLessThan:num2];
        if (isLessThan)
            return [NSNumber numberWithBool:YES];
        else 
            return [NSNumber numberWithBool:NO];

    } params:nil restArg:lessThanArgSym];
    
    CacaoSymbol * rangeSymbol = [CacaoSymbol symbolWithName:@"range" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * rangeStartArgSym = [CacaoSymbol symbolWithName:@"start" inNamespace:nil];
    CacaoSymbol * rangeEndArgSym = [CacaoSymbol symbolWithName:@"end" inNamespace:nil];
    CacaoVector * rangeArgs = [CacaoVector vectorWithArray:[NSArray arrayWithObjects: rangeStartArgSym, rangeEndArgSym, nil]];;
    CacaoFn * rangeFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoBigInteger * startNum = [argsAndVals objectForKey:rangeStartArgSym];
        CacaoBigInteger * endNum = [argsAndVals objectForKey:rangeEndArgSym];
        CacaoBigInteger * i = startNum;
        NSMutableArray * numbers = [NSMutableArray array];
        while ([i isLessThan:endNum]) {
            [numbers addObject:i];
            i = [i add:[CacaoBigInteger bigIntegerFromLongLong:1]];
        }
        return [CacaoVector vectorWithArray:numbers];

    } params:rangeArgs restArg:nil];
    
    
    //CacaoSymbol * multiplyOpSymbol = [CacaoSymbol symbolWithName:@"*" inNamespace:GLOBAL_NAMESPACE];
//    CacaoFn * multiplyFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
//        int answer = 1;
//        for (NSNumber * number in params)
//            answer *= [number intValue];
//        return [NSNumber numberWithInt:answer];
//    }];    
//    
    

//    
//    CacaoSymbol * divideOpSym = [CacaoSymbol symbolWithName:@"/" inNamespace:GLOBAL_NAMESPACE];
//    CacaoFn * divideFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
//        NSNumber * firstNumber;
//        NSArray * remainingNumbers = [params popFirstInto:&firstNumber];
//        int answer = [firstNumber intValue];
//        for (NSNumber * number in remainingNumbers)
//            answer /= [number intValue];
//        return [NSNumber numberWithInt:answer];
//    }];    
      
    NSDictionary * globalMappings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], yesSymbol,
                                     [NSNumber numberWithBool:NO], noSymbol,
                                     sumFn, sumOpSymbol, 
                                     subtractFn, subtractOpSymbol,
                                     lessThanFn, lessThanSymbol,
                                     rangeFn, rangeSymbol,
                                    // multiplyFn, multiplyOpSymbol,

//                                     divideFn, divideOpSym,
                                     nil];
    return globalMappings;
    return nil;
}


@end
