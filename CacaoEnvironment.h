//
//  CacaoEnvironment.h
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

#import <Cocoa/Cocoa.h>

#import "CacaoAST.h"
#import "CacaoFn.h"
#import "CacaoNil.h"
#import "CacaoSymbol.h"
#import "CacaoVector.h"
#import "NSArray+Functional.h"
#import "CacaoNilNotCallableException.h"
#import "CacaoSymbolNotFoundException.h"


@interface CacaoEnvironment : NSObject {
    NSMutableDictionary * mappingTable;
    CacaoEnvironment * outer;
}

@property (nonatomic, retain) NSMutableDictionary * mappingTable;
@property (nonatomic, retain) CacaoEnvironment * outer;

+ (CacaoEnvironment *)environmentWith:(NSDictionary *)paramsAndArgs outerEnvironment:(CacaoEnvironment *)theOuter;
+ (CacaoEnvironment *)environmentFromVector:(CacaoVector *)bindings 
                           outerEnvironment:(CacaoEnvironment *)theOuter;
+ (CacaoEnvironment *)globalEnvironment;
- (CacaoEnvironment *)find:(CacaoSymbol *)theVar;
- (id)getMappingValue:(CacaoSymbol *)theVar;
- (void)setVar:(id)theVar to:(id)theValue;

+ (id)evalText:(NSString *)x inEnvironment:(CacaoEnvironment *)env;
+ (id)eval:(id)expression inEnvironment:(CacaoEnvironment *)env;

+ (id)evalDefExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (id)evalLetExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (id)evalIfExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (NSNumber *)evalBooleanExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (CacaoFn *)fnFromExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (id)evalCocoaMethodCallExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (id)evalCocoaInstancingExpression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (id)evalCocoaStaticMethod:(NSString *)method forClass:(Class)theClass expression:(NSArray *)expression inEnvironment:(CacaoEnvironment *)env;
+ (void)addParams:(NSArray *)params toInvocation:(NSInvocation *)invocation;
+ (id)invokeAndGetResultFrom:(NSInvocation *)invocation;

@end
