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
    CacaoVector * sumArgs = [CacaoVector vectorWithArray:[NSArray arrayWithObject:sumArgSym]];
    CacaoFn * sumFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        int sum = 0;
        CacaoVector * numbers = [argsAndVals objectForKey:sumArgSym];
        for (NSNumber * number in numbers.elements)
            if (number)
                sum += [number intValue];
        return [NSNumber numberWithInt:sum];
    } params:sumArgs];
    
    //CacaoSymbol * multiplyOpSymbol = [CacaoSymbol symbolWithName:@"*" inNamespace:GLOBAL_NAMESPACE];
//    CacaoFn * multiplyFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
//        int answer = 1;
//        for (NSNumber * number in params)
//            answer *= [number intValue];
//        return [NSNumber numberWithInt:answer];
//    }];    
//    
//    CacaoSymbol * subtractOpSymbol = [CacaoSymbol symbolWithName:@"-" inNamespace:GLOBAL_NAMESPACE];
//    CacaoFn * subtractFn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
//        NSNumber * firstNumber;
//        NSArray * remainingNumbers = [params popFirstInto:&firstNumber];
//        int answer = [firstNumber intValue];
//        for (NSNumber * number in remainingNumbers)
//            answer -= [number intValue];
//        return [NSNumber numberWithInt:answer];
//    }];
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
                                    // multiplyFn, multiplyOpSymbol,
//                                     subtractFn, subtractOpSymbol,
//                                     divideFn, divideOpSym,
                                     nil];
    return globalMappings;
    return nil;
}


@end
