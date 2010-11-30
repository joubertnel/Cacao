//
//  CacaoEnvironment.m
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

#import "CacaoEnvironment.h"

static NSString * restParamDelimeter = @"&";
const short fnParamsIndex = 1; // index of function args in a 'fn' form
const short fnBodyIndex = 2;  // index where body forms start in a 'fn' form


@implementation CacaoEnvironment

@synthesize mappingTable;
@synthesize outer;

#pragma mark Lifecycle

+ (NSDictionary *)defaultGlobalMappings
{
    CacaoSymbol * yesSymbol = [CacaoSymbol symbolWithName:@"YES"];
    CacaoSymbol * noSymbol = [CacaoSymbol symbolWithName:@"NO"];
    
    CacaoSymbol * sumOpSymbol = [CacaoSymbol symbolWithName:@"+"];
    CacaoFn * sumFn = [CacaoFn fnWithDispatchFunction:^(NSArray * params) {
        int sum = 0;
        for (NSNumber * number in params)
            if (number)
                sum += [number intValue];
        return [NSNumber numberWithInt:sum];
    }];
    
    CacaoSymbol * multiplyOpSymbol = [CacaoSymbol symbolWithName:@"*"];
    CacaoFn * multiplyFn = [CacaoFn fnWithDispatchFunction:^(NSArray * params) {
        int answer = 1;
        for (NSNumber * number in params)
            answer *= [number intValue];
        return [NSNumber numberWithInt:answer];
    }];    
    
    CacaoSymbol * subtractOpSymbol = [CacaoSymbol symbolWithName:@"-"];
    CacaoFn * subtractFn = [CacaoFn fnWithDispatchFunction:^(NSArray * params) {
        NSNumber * firstNumber;
        NSArray * remainingNumbers = [params popFirstInto:&firstNumber];
        int answer = [firstNumber intValue];
        for (NSNumber * number in remainingNumbers)
            answer -= [number intValue];
        return [NSNumber numberWithInt:answer];
    }];
    
    CacaoSymbol * divideOpSym = [CacaoSymbol symbolWithName:@"/"];
    CacaoFn * divideFn = [CacaoFn fnWithDispatchFunction:^(NSArray * params) {
        NSNumber * firstNumber;
        NSArray * remainingNumbers = [params popFirstInto:&firstNumber];
        int answer = [firstNumber intValue];
        for (NSNumber * number in remainingNumbers)
            answer /= [number intValue];
        return [NSNumber numberWithInt:answer];
    }];    
      
    NSDictionary * globalMappings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], yesSymbol,
                                     [NSNumber numberWithBool:NO], noSymbol,
                                     sumFn, sumOpSymbol, 
                                     multiplyFn, multiplyOpSymbol,
                                     subtractFn, subtractOpSymbol,
                                     divideFn, divideOpSym,
                                     nil];
    return globalMappings;
}



+ (CacaoEnvironment *)environmentWith:(NSDictionary *)defaultMappings outerEnvironment:(CacaoEnvironment *)theOuter
{
    CacaoEnvironment * environment = [[CacaoEnvironment alloc] init];
    [environment setOuter:theOuter];    
    [environment setMappingTable:[NSMutableDictionary dictionaryWithDictionary:defaultMappings]];
    return [environment autorelease];
}

+ (CacaoEnvironment *)environmentFromVector:(CacaoVector *)bindings 
                           outerEnvironment:(CacaoEnvironment *)theOuter;
{
    CacaoEnvironment * environment = [[CacaoEnvironment alloc] init];
    [environment setOuter:theOuter];
    NSUInteger symValPairCount = [bindings count] / 2;
    NSMutableDictionary * mappings = [NSMutableDictionary dictionaryWithCapacity:symValPairCount];
    [environment setMappingTable:mappings];
    int symIndex = 0;
    int lastSymIndex = (symValPairCount * 2) - 2;
    while (symIndex <= lastSymIndex) {
        CacaoSymbol *sym = [bindings objectAtIndex:symIndex];
        id valExpression = [bindings objectAtIndex:symIndex+1];
        id val = [CacaoEnvironment eval:valExpression inEnvironment:environment];
        [mappings setObject:val forKey:sym];
        symIndex = symIndex + 2;
    }

    return [environment autorelease];
}

+ (CacaoEnvironment *)globalEnvironment
{
    CacaoEnvironment * environment = [CacaoEnvironment environmentWith:[CacaoEnvironment defaultGlobalMappings]
                                                      outerEnvironment:nil];
    return environment;                                        
}


#pragma mark Locate symbols in the environment

- (id)find:(id)theVar
{
    id val = [self getMappingValue:theVar];
    if (val == nil)
    {
        if (self.outer)
            return [self.outer find:theVar];  
        else {
            // theVar hasn't been found in the environment or any of its parent environments
            NSString * errorMessage = [NSString stringWithFormat:@"'%@' not found in the environment.", [theVar printable]];
            [CacaoSymbolNotFoundException raise:[CacaoSymbolNotFoundException name]
                                         format:errorMessage];
            return nil;
        }
    }
    else return self;
}

- (id)getMappingValue:(id)theVar
{
    __block id val = nil;
    
    [self.mappingTable enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        BOOL bothSymbols = ([key isKindOfClass:[CacaoSymbol class]]) && ([theVar isKindOfClass:[CacaoSymbol class]]);        
        BOOL symbolMatch =  bothSymbols && ([[(CacaoSymbol *)key name] isEqualToString:[(CacaoSymbol *)theVar name]]);
        BOOL otherMatch = !symbolMatch && (key == theVar);
        
        if (symbolMatch || otherMatch)
        {
            val = obj;
            *stop = YES;
        }               
    }];
    return val;
}

- (void)setVar:(id)theVar to:(id)theValue
{
    [self.mappingTable setObject:theValue forKey:theVar];
}


#pragma mark Evaluation

+ (id)eval:(id)x inEnvironment:(CacaoEnvironment *)env
{
    if ([x isKindOfClass:[CacaoSymbol class]])
        return [[env find:x] getMappingValue:x];
    else if (![x isKindOfClass:[NSArray class]])
        return x;    
    
    // Special Forms    
    NSArray * expression = (NSArray *)x;
    CacaoSymbol * firstX = (CacaoSymbol *)[expression objectAtIndex:0];
    if ([firstX.stringValue isEqualToString:@"def"])
    {
        CacaoSymbol * symbol = [expression objectAtIndex:1];
        id subExpression = [expression objectAtIndex:2];
        [env setVar:symbol to:[self eval:subExpression inEnvironment:env]];
        return nil;
    }
    else if ([firstX.stringValue isEqualToString:@"let"])
    {        
        CacaoVector *bindings = [CacaoVector vectorWithArray:[expression objectAtIndex:1]];
        NSRange bodyRange;
        bodyRange.location = 2;
        bodyRange.length = expression.count - bodyRange.location;
        NSArray *body = [expression subarrayWithRange:bodyRange];
        CacaoEnvironment * subEnv = [CacaoEnvironment environmentFromVector:bindings
                                                           outerEnvironment:env]; 
        id returnVal = nil;
        for (id bodyExpr in body) {
            returnVal = [CacaoEnvironment eval:bodyExpr inEnvironment:subEnv];
        }
        return returnVal;
    }
    else if ([firstX.stringValue isEqualToString:@"if"])
    {
        id testExpression = [expression objectAtIndex:1];
        id thenExpresison = [expression objectAtIndex:2];
        id elseExpression = [expression objectAtIndex:3];
        BOOL testResult = [[CacaoEnvironment eval:testExpression inEnvironment:env] boolValue];
        if (testResult)
            return [CacaoEnvironment eval:thenExpresison inEnvironment:env];
        else 
            return [CacaoEnvironment eval:elseExpression inEnvironment:env];
        
    }
    else if ([firstX.stringValue isEqualToString:@"="])
    {
        id first = [CacaoEnvironment eval:[expression objectAtIndex:1]
                            inEnvironment:env];
        id second = [CacaoEnvironment eval:[expression objectAtIndex:2]
                             inEnvironment:env];
        BOOL isEqual = [first isEqual:second];
        return [NSNumber numberWithBool:isEqual];
    }
    else if ([firstX.stringValue isEqualToString:@"fn"])
    {        
        NSRange bodyRange;
        bodyRange.location = fnBodyIndex;
        bodyRange.length = expression.count - bodyRange.location;
        NSArray *body = [expression subarrayWithRange:bodyRange];
        
        CacaoVector *params = (CacaoVector *)[expression objectAtIndex:fnParamsIndex];
        CacaoSymbol *restParam = nil;
        NSArray * positionalParams = [params elements];
        NSUInteger positionalArgsCount = [positionalParams count];
        NSInteger butLastParamIndex = [positionalParams count] - 2;
        
        if (butLastParamIndex >= 0)
        {
            CacaoSymbol *butLastParam = [positionalParams objectAtIndex:butLastParamIndex];
            if ([[butLastParam name] isEqualToString:restParamDelimeter])
            {                
                restParam = [positionalParams objectAtIndex:butLastParamIndex+1];                                
                positionalArgsCount = positionalArgsCount - 2;
                NSRange positionalArgsRange;
                positionalArgsRange.location = 0;
                positionalArgsRange.length = positionalArgsCount;
                positionalParams = [positionalParams subarrayWithRange:positionalArgsRange];
            }
        }
        
        DispatchFunction fnOp = ^(NSArray * args) {
            NSMutableDictionary * paramsAndArgs = nil;
            if ([positionalParams count] > 0)
                paramsAndArgs = [NSMutableDictionary dictionaryWithObjects:args forKeys:positionalParams];
            else
                paramsAndArgs = [NSMutableDictionary dictionaryWithCapacity:1];
            
            if (restParam != nil)
            {
                NSRange restRange = NSMakeRange(positionalArgsCount, [args count] - positionalArgsCount);
                NSArray *restArgs = [args subarrayWithRange:restRange];
                [paramsAndArgs setObject:restArgs forKey:restParam];
            }

            CacaoEnvironment * subEnv = [CacaoEnvironment environmentWith:paramsAndArgs outerEnvironment:env];
            __block NSObject * result;
            NSUInteger lastExpressionIndex = [body count] - 1;
            [body enumerateObjectsUsingBlock:^(id bodyExpression, NSUInteger idx, BOOL *stop) {
                if (idx == lastExpressionIndex) {
                    result = (NSObject *)[CacaoEnvironment eval:bodyExpression inEnvironment:subEnv];                    
                }
                else {
                    [CacaoEnvironment eval:bodyExpression inEnvironment:subEnv];
                }
            }];
            
            return result;
        };        
        
        CacaoFn *fn = [CacaoFn fnWithDispatchFunction:fnOp];
        return fn;
    }
    else
    {
        NSArray * expressions = [x map:^(id subExpression) {
            return [self eval:subExpression inEnvironment:env];
        }];
        
        NSObject * func;
        NSArray * remainingExpressions = [expressions popFirstInto:&func];  
        
        if ([func isKindOfClass:[CacaoNil class]])
            [CacaoNilNotCallableException raise:[CacaoNilNotCallableException name] format:@"Can't call nil'"];
        
        CacaoFn *funcBlock = (CacaoFn *)func;
        return [funcBlock invokeWithParams:remainingExpressions];
    }
}


@end
