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

#import <objc/runtime.h>

#import "CacaoArgumentName.h"
#import "CacaoCore.h"
#import "CacaoDictionary.h"
#import "CacaoFn.h"
#import "CacaoSymbol.h"
#import "BigInteger.h"
#import "NSArray+Functional.h"


NSString * GLOBAL_NAMESPACE = @"cacao";
static NSString * SYMBOL_NAME_YES = @"YES";
static NSString * SYMBOL_NAME_NO = @"NO";

@implementation CacaoCore


+ (NSDictionary *)functions
{
    CacaoSymbol * yesSymbol = [CacaoSymbol symbolWithName:SYMBOL_NAME_YES inNamespace:GLOBAL_NAMESPACE];
    CacaoSymbol * noSymbol = [CacaoSymbol symbolWithName:SYMBOL_NAME_NO inNamespace:GLOBAL_NAMESPACE];
    
    NSMutableDictionary * globalMappings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithBool:YES], yesSymbol,
                                            [NSNumber numberWithBool:NO], noSymbol,
                                            nil];
    
    NSArray * functionMakingClasses = [NSArray arrayWithObjects:
                                       @"CacaoComparisonFunctionMakers",
                                       @"CacaoHigherOrderFunctionMakers",
                                       @"CacaoMathFunctionMakers",                                       
                                       @"CacaoSequenceFunctionMakers",
                                       nil];
    
    
    // Call all the class methods of the function making classes, adding
    // the functions they make to to the global mappings dictionary.
    
    for (NSString * className in functionMakingClasses) {
        unsigned int methodCount;
        Class class = NSClassFromString(className);
        Method * methods = class_copyMethodList(object_getClass(class), &methodCount);
        for (NSUInteger i=0; i < methodCount; i++) {
            SEL selector = method_getName(methods[i]);
            id result = [class performSelector:selector];
            if ([result isKindOfClass:[NSDictionary class]])
                [globalMappings addEntriesFromDictionary:(NSDictionary*)result];
        }
    }   
       
    return globalMappings;
}


@end
