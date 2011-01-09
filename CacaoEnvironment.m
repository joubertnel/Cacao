//
//  CacaoEnvironment.m
//  Cacao
//
//  Provides lexical scope and evaluation of forms (forms and expressions).
//
////////////////////////////////////////////////////////////////////////////////////
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

#import <objc/objc-runtime.h>
#import <ObjCHiredis/ObjCHiredis.h>
#import "BigInteger.h"
#import "CacaoCore.h"
#import "CacaoDictionary.h"
#import "CacaoEnvironment.h"
#import "CacaoKeyword.h"
#import "CacaoLispReader.h"
#import "PushbackReader.h"
#import "CacaoArgumentName.h"
#import "CacaoQuotedForm.h"

static NSString * REST_PARAM_DELIMITER = @"&";

static NSString * SPECIAL_FORM_TEXT_DEF = @"def";
static NSString * SPECIAL_FORM_TEXT_LET = @"let";
static NSString * SPECIAL_FORM_TEXT_IF = @"if";
static NSString * SPECIAL_FORM_TEXT_EQUALS = @"=";
static NSString * SPECIAL_FORM_TEXT_INSTANCING = @"new";
static NSString * SPECIAL_FORM_TEXT_MEMBERACCESS = @".";
static NSString * SPECIAL_FORM_TEXT_FN = @"fn";

static const short fnParamsIndex = 1; // index of function args in a 'fn' form
static const short fnBodyIndex = 2;  // index where body forms start in a 'fn' form


@implementation CacaoEnvironment

@synthesize mappingTable;
@synthesize outer;


#pragma mark Lifecycle




+ (CacaoEnvironment *)environmentWith:(NSDictionary *)paramsAndArgs outerEnvironment:(CacaoEnvironment *)theOuter
{
    CacaoEnvironment * environment = [[CacaoEnvironment alloc] init];
    [environment setOuter:theOuter];    
    [environment setMappingTable:[NSMutableDictionary dictionaryWithDictionary:paramsAndArgs]];
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
    CacaoEnvironment * environment = [CacaoEnvironment environmentWith:[CacaoCore functions]
                                                      outerEnvironment:nil];
    return environment;                                        
}


#pragma mark Locate symbols in the environment

- (id)find:(CacaoSymbol *)theVar
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

- (id)getMappingValue:(CacaoSymbol *)theVar
{        
    __block id val = nil;
    BOOL isTheVarOfCacaoSymbolClass = [theVar isKindOfClass:[CacaoSymbol class]];
    
    [self.mappingTable enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BOOL bothSymbols = ([key isKindOfClass:[CacaoSymbol class]]) && isTheVarOfCacaoSymbolClass;        
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

+ (id)evalText:(NSString *)x inEnvironment:(CacaoEnvironment *)env
{
    NSData * inputData = [x dataUsingEncoding:NSUTF8StringEncoding];
    NSInputStream * stream = [NSInputStream inputStreamWithData:inputData];
    [stream open];
    PushbackReader * reader = [[PushbackReader alloc] init:stream];
    NSObject * readerOutput = [CacaoLispReader readFrom:reader eofValue:nil];
    NSObject * result = [CacaoEnvironment eval:readerOutput inEnvironment:env];
    [reader release];
    [stream close];
    return result;
}

+ (id)eval:(id)x inEnvironment:(CacaoEnvironment *)env
{
    if ([x isKindOfClass:[CacaoSymbol class]])
        // If x is a symbol, look up its value in the environment
        return [[env find:x] getMappingValue:x];
    else if ([x isKindOfClass:[CacaoVector class]])
    {
        // If x is a vector, evaluate each item in the vector and return a new vector of the resuls
        NSArray * evaluatedItems = [[x elements] map:^(id object) {
            return [CacaoEnvironment eval:object inEnvironment:env];
        }];        
        return [CacaoVector vectorWithArray:evaluatedItems];
    }
    else if ([x isKindOfClass:[CacaoQuotedForm class]])
    {
        BOOL formEvaluatesToItself = ([[x form] isKindOfClass:[BigInteger class]] ||
                                      [[x form] isKindOfClass:[NSString class]]);
        if (formEvaluatesToItself)
            return [x form];
        else
            return x;
    }
    else if (![x isKindOfClass:[NSArray class]])
        return x;      

   
    // Special Forms    
    
    NSArray * expression = (NSArray *)x;
    CacaoSymbol * firstX = (CacaoSymbol *)[expression objectAtIndex:0];
    
    // Test whether firstX refers to a Cocoa static class method
    NSArray * qualifiedClassMethod = [[firstX stringValue] pathComponents];
    if ([qualifiedClassMethod count] == 2)
    {
        Class theClass = NSClassFromString([qualifiedClassMethod objectAtIndex:0]);
        if (theClass != nil)
        {
            return [CacaoEnvironment evalCocoaStaticMethod:[qualifiedClassMethod objectAtIndex:1]
                                                  forClass:theClass
                                                expression:expression 
                                             inEnvironment:env];
        }
    }
    
    if ([firstX.stringValue isEqualToString:SPECIAL_FORM_TEXT_DEF])
    {
        return [CacaoEnvironment evalDefExpression:expression inEnvironment:env];
    }
    else if ([firstX.stringValue isEqualToString:SPECIAL_FORM_TEXT_LET])
    {        
        return [CacaoEnvironment evalLetExpression:expression inEnvironment:env];
    }
    else if ([firstX.stringValue isEqualToString:SPECIAL_FORM_TEXT_IF])
    {
        return [CacaoEnvironment evalIfExpression:expression inEnvironment:env];        
    }
    else if ([firstX.stringValue isEqualToString:SPECIAL_FORM_TEXT_EQUALS])
    {
        return [CacaoEnvironment evalBooleanExpression:expression inEnvironment:env];
    }
    else if ([firstX.stringValue isEqualToString:SPECIAL_FORM_TEXT_INSTANCING])
    {
        return [CacaoEnvironment evalCocoaInstancingExpression:expression inEnvironment:env];
    }
    else if ([[firstX.stringValue substringToIndex:1] isEqualToString:SPECIAL_FORM_TEXT_MEMBERACCESS])
    {
        return [CacaoEnvironment evalCocoaMethodCallExpression:expression inEnvironment:env];
    }
    else if ([firstX.stringValue isEqualToString:SPECIAL_FORM_TEXT_FN])
    {        
        return [CacaoEnvironment fnFromExpression:expression inEnvironment:env];
    }
    else if ([firstX isKindOfClass:[CacaoKeyword class]])
    {
        CacaoSymbol * dictSym = [expression objectAtIndex:1];
        CacaoDictionary * dict = [CacaoEnvironment eval:dictSym inEnvironment:env];        
        id value = [dict.elements objectForKey:firstX];
        return value;    
    }
    else return [CacaoEnvironment evalFunctionCall:x inEnvironment:env];
}


#pragma mark Evaluation helpers 

+ (id)evalFunctionCall:(NSArray *)x inEnvironment:(CacaoEnvironment *)env
{
#if DEBUG
    NSLog(@"Eval Function Call:");
    [x enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {        
        NSLog(@"\t%@", [obj printable]);
    }];
    
#endif
    
   
    // X is a function call. Apply the arguments against it. 
    
    NSArray * expressions = [x map:^(id subExpression) {
        return [self eval:subExpression inEnvironment:env];
    }];
    
    NSObject * func;
    NSArray * remainingExpressions = [expressions popFirstInto:&func];
    
    if ([func isKindOfClass:[CacaoNil class]])
        [CacaoNilNotCallableException raise:[CacaoNilNotCallableException name] format:@"Can't call nil'"];
    
    CacaoFn *funcBlock = (CacaoFn *)func; 
    
    // Create an environment for the function, which is an implicit LET of 
    // the arguments and their values
    
    NSMutableArray * symbolBindings = [NSMutableArray array];
    __block BOOL prevObjectWasArgumentName = NO;
    __block BOOL restArgsWereSpecified = NO;
    __block NSUInteger lastNonRestArgIndex = 0;

    
    [remainingExpressions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[CacaoArgumentName class]])
        {
            CacaoSymbol * sym = [(CacaoArgumentName *)obj symbol];
            [symbolBindings addObject:sym];            
            prevObjectWasArgumentName = YES;
        } else if (prevObjectWasArgumentName == NO) {
            // We've reached the first REST argument, so break out of the enumeration,
            // so that we can add the REST argument(s).
            restArgsWereSpecified = YES;
            lastNonRestArgIndex = idx - 1;
            *stop = YES;
        } else {
            // We are on a named argument's value, so let's add it to the symbol 
            // bindings
            [symbolBindings addObject:obj];
            prevObjectWasArgumentName = NO;
        }
    }];
    
    if ([funcBlock restArg] != nil)
    {
        // The function signature allows for REST args, so lets add.
        // The rest arguments are not named in the function call, so we have to gather 
        // its name from the function metadata and add it
        // to the symbol bindings.
        CacaoSymbol * restArgNameSym = [funcBlock restArg];
        [symbolBindings addObject:restArgNameSym];
        
        // REST args are optional; if the function was invoked with REST args specified, 
        // add them, otherwise add an empty vector.
        CacaoVector * restArgs;
        if (restArgsWereSpecified)
        {
            NSUInteger restArgsStartIndex = lastNonRestArgIndex + 1;
            NSRange restRange = {.location=restArgsStartIndex, .length=[remainingExpressions count]-restArgsStartIndex};
            restArgs = [CacaoVector vectorWithArray:[remainingExpressions subarrayWithRange:restRange]];
        }
        else {
            restArgs = [CacaoVector vectorWithArray:[NSArray array]];
        }
        [symbolBindings addObject:restArgs];

    }
    
    
    CacaoVector * bindings = [CacaoVector vectorWithArray:symbolBindings];
    CacaoEnvironment * functionEnvironment = [CacaoEnvironment environmentFromVector:bindings
                                                                    outerEnvironment:env];        
    
    // Resolve arguments' values by looking them up in the environment, and invoke the function
    // with the arguments and values. 
    int argCount = [symbolBindings count];
    NSMutableArray * argsAndValues = [NSMutableArray arrayWithCapacity:argCount*2];
    for (int i=0; i < argCount; i=i+2) {
        CacaoSymbol * argNameSym = [symbolBindings objectAtIndex:i];
        id val = [[functionEnvironment find:argNameSym] getMappingValue:argNameSym];
        CacaoArgumentName * argName = [CacaoArgumentName argumentNameInternedFromSymbol:argNameSym];
        [argsAndValues addObjectsFromArray:[NSArray arrayWithObjects:argName, val, nil]];
    }
    
    return [funcBlock invokeWithArgsAndVals:argsAndValues];    
}

+ (id)evalDefExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env
{
    CacaoSymbol * symbol = [expression objectAtIndex:1];
    id subExpression = [expression objectAtIndex:2];
    [env setVar:symbol to:[self eval:subExpression inEnvironment:env]];
    return nil;
}

+ (id)evalLetExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env
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

+ (id)evalIfExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env
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

+ (NSNumber *)evalBooleanExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env
{
    id first = [CacaoEnvironment eval:[expression objectAtIndex:1]
                        inEnvironment:env];
    id second = [CacaoEnvironment eval:[expression objectAtIndex:2]
                         inEnvironment:env];
    BOOL isEqual = [first isEqual:second];
    return [NSNumber numberWithBool:isEqual];
}

+ (CacaoFn *)fnFromExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env
{
    NSRange bodyRange;
    bodyRange.location = fnBodyIndex;
    bodyRange.length = expression.count - bodyRange.location;
    NSArray * body = [expression subarrayWithRange:bodyRange];
    
    CacaoVector * params = (CacaoVector *)[expression objectAtIndex:fnParamsIndex];
    
    // Extract the REST param, if there is one
    __block NSUInteger restParamDelimiterIndex = 0;
    __block CacaoSymbol * restParam = nil;

    [params.elements enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[CacaoSymbol class]])
        {
            CacaoSymbol * argSym = (CacaoSymbol *)obj;
            NSString * symName = [argSym name];
            if ([symName hasPrefix:REST_PARAM_DELIMITER])
            {
                restParamDelimiterIndex = idx;
                if ([symName isEqualToString:REST_PARAM_DELIMITER])
                    restParam = [params objectAtIndex:restParamDelimiterIndex + 1];
                else 
                {
                    NSString * restParamName = [symName substringFromIndex:1];
                    restParam = [CacaoSymbol symbolWithName:restParamName inNamespace:[argSym ns]];
                }
                *stop = YES;
            }
        }
    }];
    
    // Build a vector of the named args, and also extract the default values (if any)
    NSRange regularParamsRange = {.location=0};
    regularParamsRange.length = (restParam == nil) ? [params.elements count] : restParamDelimiterIndex;
    NSArray * argTokens = [params.elements subarrayWithRange:regularParamsRange];
    NSMutableArray * argSymbols = [NSMutableArray arrayWithCapacity:[argTokens count]];
    NSMutableDictionary * argsDefaultVals = [NSMutableDictionary dictionary];

    int i=0;
    int c=[argTokens count];
    while (i < c) {
        CacaoSymbol * argTokenSym = [argTokens objectAtIndex:i];
        CacaoSymbol * argNameSym = nil;

        if ([argTokenSym.name hasSuffix:@"="])
        {
            // This token has a default value - the next token (which is already evaluated)
            i++;
            NSObject * defaultValue = [argTokens objectAtIndex:i];
            NSString * argName = [argTokenSym.name stringByReplacingOccurrencesOfString:@"=" withString:@""];
            argNameSym = [CacaoSymbol symbolWithName:argName inNamespace:[argTokenSym ns]];            
            [argsDefaultVals setObject:defaultValue forKey:argNameSym];
        }
        else {
            // This token may or may not have a default value. Split the token by '='
            // and if a default value was specified, there will be two parts; the first
            // part is the argument name and the second part is the default value
            NSArray * argParts = [argTokenSym.name componentsSeparatedByString:@"="];
            NSString * argName = [argParts objectAtIndex:0];
            argNameSym = [CacaoSymbol symbolWithName:argName inNamespace:[argTokenSym ns]];            
            
            // A default value is specified, but it is not evaluated yet. Evaluate it and add it to 
            // the default values dictionary.
            if ([argParts count] == 2)
            {
                NSObject * val = [CacaoEnvironment evalText:[argParts objectAtIndex:1] inEnvironment:env];
                [argsDefaultVals setObject:val forKey:argNameSym];
            }            
        }   
        
        [argSymbols addObject:argNameSym];        
        i++;        
    }
  
    params = [CacaoVector vectorWithArray:argSymbols];
    
    
    // Prepare the function
    
    DispatchFunction fnOp = ^(NSDictionary * argsAndVals) {        
        CacaoEnvironment * subEnv = [CacaoEnvironment environmentWith:argsAndVals outerEnvironment:env];
        __block NSObject * result;
        NSUInteger lastExpressionIndex = [body count] - 1;
        [body enumerateObjectsUsingBlock:^(id bodyExpression, NSUInteger idx, BOOL *stop) {
            if (idx == lastExpressionIndex)
            {
                result = (NSObject *)[CacaoEnvironment eval:bodyExpression inEnvironment:subEnv];
            }
            else {
                [CacaoEnvironment eval:bodyExpression inEnvironment:subEnv];
            }
        }];
        
        return result;
    };
    
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:fnOp
                                              args:params
                                      argsDefaults:argsDefaultVals
                                           restArg:restParam];
    
    return fn;
}

+ (id)evalCocoaMethodCallExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env
{
    CacaoSymbol * firstX = (CacaoSymbol *)[expression objectAtIndex:0];
    id cocoaInstance = [CacaoEnvironment eval:[expression objectAtIndex:1] inEnvironment:env];
    NSString * methodName = [firstX.stringValue substringFromIndex:1];                
    
    SEL methodSelector = NSSelectorFromString(methodName);
    if (YES) //[cocoaInstance respondsToSelector:methodSelector])
    {               
        NSMethodSignature * methodSignature = [cocoaInstance methodSignatureForSelector:methodSelector];
                
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setSelector:methodSelector];
        [invocation setTarget:cocoaInstance];
        
        NSRange paramsRange;
        paramsRange.location = 2;
        paramsRange.length = expression.count - paramsRange.location;
        NSArray * params = [expression subarrayWithRange:paramsRange];
        
        [CacaoEnvironment addParams:params toInvocation:invocation];        
        return [CacaoEnvironment invokeAndGetResultFrom:invocation];
    }
    return nil;    
}

+ (id)evalCocoaInstancingExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env
{
    CacaoSymbol * cocoaClassNameSymbol = [expression objectAtIndex:1];
    NSString * cocoaClassName = [cocoaClassNameSymbol name];
    id cocoaObject = [[NSClassFromString(cocoaClassName) alloc] init];
    return [cocoaObject autorelease];
}

+ (id)evalCocoaStaticMethod:(NSString *)methodName forClass:(Class)theClass expression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
{
    SEL methodSelector = NSSelectorFromString(methodName);
    NSMethodSignature * methodSignature = [theClass methodSignatureForSelector:methodSelector];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:methodSelector];
    [invocation setTarget:theClass];
    NSRange paramsRange;
    paramsRange.location = 1;
    paramsRange.length = expression.count - paramsRange.location;
    NSArray * params = [expression subarrayWithRange:paramsRange];
    
    [CacaoEnvironment addParams:params toInvocation:invocation];
    return [CacaoEnvironment invokeAndGetResultFrom:invocation];
}


#pragma mark Cocoa integration support

+ (void)addParams:(NSArray *)params toInvocation:(NSInvocation *)invocation
{
    NSMethodSignature * methodSignature = [invocation methodSignature];
    
    [params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int argumentIndex = idx + 2; //self and _cmd are at 0 and 1
        char const * argType = [methodSignature getArgumentTypeAtIndex:argumentIndex];
        
        if (strcmp(argType, @encode(unsigned long long)) == 0)
        {
            NSUInteger theVal = [obj longLongValue];
            [invocation setArgument:&theVal atIndex:argumentIndex];
        }
        else if (strcmp(argType, @encode(id)) == 0)
        {
            [invocation setArgument:&obj atIndex:argumentIndex];
        }
    }];    
}

+ (id)invokeAndGetResultFrom:(NSInvocation *)invocation
{
    id result = nil;
    [invocation invoke];
    const char * returnType = [[invocation methodSignature] methodReturnType];
    
    if (strcmp(returnType, @encode(id)) == 0)
    {
        [invocation getReturnValue:&result];
    }
    else
    {
        id result = nil;
        
        if (strcmp(returnType, @encode(long long)) == 0)
        {
            NSInteger returnValue;
            [invocation getReturnValue:&returnValue];
            result = [NSNumber numberWithLongLong:returnValue];
        }
        else if (strcmp(returnType, @encode(unichar)) == 0)
        {
            char * returnValue = malloc(2);
            [invocation getReturnValue:returnValue];
            result = [NSString stringWithCString:returnValue encoding:NSUTF8StringEncoding];
            free(returnValue);
        }
        else if (strcmp(returnType, @encode(unsigned long long)) == 0)
        {
            NSUInteger returnValue;
            [invocation getReturnValue:&returnValue];
            result = [NSNumber numberWithUnsignedLongLong:returnValue];            
        }
        else if (strcmp(returnType, @encode(double)) == 0)
        {
            double returnValue;
            [invocation getReturnValue:&returnValue];
            result = [NSNumber numberWithDouble:returnValue];
        }
        else if (strcmp(returnType, @encode(float)) == 0)
        {
            float retVal;
            [invocation getReturnValue:&retVal];
            result = [NSNumber numberWithFloat:retVal];
        }
        else if (strcmp(returnType, @encode(char)) == 0)
        {
            char retVal;
            [invocation getReturnValue:&retVal];
            result = [NSNumber numberWithChar:retVal];
        }
        else if (strcmp(returnType, @encode(NSRange)) == 0)
        {
            NSRange retVal;
            [invocation getReturnValue:&retVal];
            result = [NSValue valueWithRange:retVal];
        }

        return result;
    }            
    
    return result;
}

@end
