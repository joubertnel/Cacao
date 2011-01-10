//
//  CacaoSequenceFunctionMakers.m
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

#import "CacaoSequenceFunctionMakers.h"
#import "BigInteger.h"
#import "CacaoCore.h"
#import "CacaoDictionary.h"
#import "CacaoVector.h"


@implementation CacaoSequenceFunctionMakers

+ (NSString *)namespace
{
    return GLOBAL_NAMESPACE;
}

+ (NSDictionary *)get
{
    CacaoSymbol * sym = [CacaoSymbol symbolWithName:@"get" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * idxArgSym = [CacaoSymbol symbolWithName:@"i" inNamespace:nil];
    CacaoSymbol * vecArgSym = [CacaoSymbol symbolWithName:@"vec" inNamespace:nil];
    CacaoVector * args = [CacaoVector vectorWithArray:[NSArray arrayWithObjects:idxArgSym, vecArgSym, nil]];
    
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * vec = [argsAndVals objectForKey:vecArgSym];        
        BigInteger * index = [argsAndVals objectForKey:idxArgSym];
        NSUInteger i = [[index stringValue] longLongValue];
        return [vec objectAtIndex:i];
    } args:args restArg:nil];
    
    return [NSDictionary dictionaryWithObject:fn forKey:sym];
}


+ (NSDictionary *)range
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"range" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * startArgSym = [CacaoSymbol symbolWithName:@"start" inNamespace:nil];
    CacaoSymbol * endArgSym = [CacaoSymbol symbolWithName:@"end" inNamespace:nil];
    CacaoVector * args = [CacaoVector vectorWithArray:[NSArray arrayWithObjects: startArgSym, endArgSym, nil]];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        BigInteger * startNum = [argsAndVals objectForKey:startArgSym];
        BigInteger * endNum = [argsAndVals objectForKey:endArgSym];
        BigInteger * step = [BigInteger bigIntegerWithValue:@"1"];
        
        LazyGenerator rangeNextGenerator = ^(id previous, NSUInteger index, BOOL *stop) {
            BigInteger * previousNum = (BigInteger *)previous;
            BigInteger * nextNum = [previousNum add:step];
            
            if ([nextNum isLessThan:endNum])
                return nextNum;            
            else {
                *stop = YES;
                return nil;
            }
        };      
        
        CacaoVector * lazyVec = [CacaoVector vectorWithFirstItem:startNum subsequentGenerator:rangeNextGenerator];
        return lazyVec;
    } args:args restArg:nil];
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}

+ (NSDictionary *)contains
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"contains?" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * itemArgSym = [CacaoSymbol symbolWithName:@"item" inNamespace:nil];
    CacaoSymbol * seqArgSym = [CacaoSymbol symbolWithName:@"vec" inNamespace:nil];
    CacaoVector * args = [CacaoVector vectorWithArray:[NSArray arrayWithObjects:itemArgSym, seqArgSym, nil]];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoVector * vec = (CacaoVector *)[argsAndVals objectForKey:seqArgSym];
        id obj = [argsAndVals objectForKey:itemArgSym];
        return [NSNumber numberWithBool:[vec containsObject:obj]];
    } args:args restArg:nil];
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}

+ (NSDictionary *)keys
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"keys" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * dictArgSym = [CacaoSymbol symbolWithName:@"dict" inNamespace:nil];
    CacaoVector * args = [CacaoVector vectorWithArray:[NSArray arrayWithObjects:dictArgSym, nil]];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoDictionary * dict = (CacaoDictionary *)[argsAndVals objectForKey:dictArgSym];
        return [CacaoVector vectorWithArray:[dict.elements allKeys]]; 
    } args:args restArg:nil];
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}

+ (NSDictionary *)vals
{
    CacaoSymbol * symbol = [CacaoSymbol symbolWithName:@"vals" inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * dictArgSym = [CacaoSymbol symbolWithName:@"dict" inNamespace:nil];
    CacaoVector * args = [CacaoVector vectorWithArray:[NSArray arrayWithObjects:dictArgSym, nil]];
    CacaoFn * fn = [CacaoFn fnWithDispatchFunction:^(NSDictionary * argsAndVals) {
        CacaoDictionary * dict = (CacaoDictionary *)[argsAndVals objectForKey:dictArgSym];
        return [CacaoVector vectorWithArray:[dict.elements allValues]];
    } args:args restArg:nil];
    return [NSDictionary dictionaryWithObject:fn forKey:symbol];
}


@end