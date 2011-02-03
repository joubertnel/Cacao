//
//  CacaoHigherOrderFunctionMakers.m
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

#import "CacaoHigherOrderFunctionMakers.h"
#import "CacaoCore.h"


@implementation CacaoHigherOrderFunctionMakers

+ (NSString *)namespace
{
    return GLOBAL_NAMESPACE;
}


+ (NSDictionary *)map
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"map" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * fnArgSym = [CacaoSymbol symbolWithName:@"fn" inNamespace:nil];
    CacaoSymbol * seqArgSym = [CacaoSymbol symbolWithName:@"vec" inNamespace:nil];
    CacaoVector * args = [CacaoVector vectorWithArray:[NSArray arrayWithObjects:fnArgSym, seqArgSym, nil]]; 
    
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * seq = (CacaoVector *)[argsAndVals objectForKey:seqArgSym];
        
        CacaoFn * fn = [argsAndVals objectForKey:fnArgSym];
        NSString * fnArgNameString = [fn.argNames anyObject];
        CacaoArgumentName * fnArgName = [CacaoArgumentName argumentNameInternedFromSymbol:[CacaoSymbol symbolWithName:fnArgNameString 
                                                                                                          inNamespace:nil]];
        
        if ([seq isFullyMaterialized])
        {
            __block CacaoVector * resultVector = [CacaoVector vectorWithDictionary:[NSDictionary dictionary]];
            
            [seq.materializedItems enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
                NSObject * r = [fn invokeWithArgsAndVals:[NSArray arrayWithObjects:fnArgName, obj, nil]];
                if (r == nil)
                    r = [NSNull null];                               
                [resultVector.materializedItems setObject:r forKey:key];
            }];            
            
            return resultVector;
        }
        else 
        {
            LazyGenerator mapGenerator = ^(NSUInteger index, BOOL *stop) {
                id seqItem = [seq objectAtIndex:index];
                if (seqItem)
                {
                    id r = [fn invokeWithArgsAndVals:[NSArray arrayWithObjects:fnArgName, seqItem, nil]];
                    if (r == nil)
                        r = [NSNull null];
                    return r;                
                }
                else {
                    *stop = YES;
                    return nil;
                }
            };
            
            id firstItem = mapGenerator(0, nil);
            
            CacaoVector * lazyResultVector = [CacaoVector vectorWithFirstItem:firstItem 
                                                          subsequentGenerator:mapGenerator];
            return lazyResultVector;
        }
        
    } args:args restArg:nil];
    
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}

@end
