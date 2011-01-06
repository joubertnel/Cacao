//
//  CacaoFn.m
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

#import "CacaoFn.h"
#import "CacaoArgumentName.h"
#import "CacaoSymbol.h"

NSString * const FnIdentityPrefix = @"Fn_";


@implementation CacaoFn

@synthesize func;
@synthesize identity;
@synthesize argNames;
@synthesize argsDefaultVals;
@synthesize restArg;

- (CacaoFn *)init
{
    self = [super init];

    // Create a string representation of the Fn object
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    [self setIdentity:[NSString stringWithFormat:@"%@%@", FnIdentityPrefix, (NSString *)uuidString]];        
    CFRelease(uuidString);
    CFRelease(uuidRef);

    return self;
}

+ (CacaoFn *)fnWithDispatchFunction:(DispatchFunction)theFunc 
                               args:(CacaoVector *)theArgs
                       argsDefaults:(NSDictionary *)theArgsDefaultVals
                            restArg:(CacaoSymbol *)theRestArg
{
    CacaoFn * fn = [[CacaoFn alloc] init];
    [fn setFunc:theFunc];    
    NSMutableSet * theArgNames = [NSMutableSet setWithCapacity:theArgs.count];
    
    for (CacaoSymbol * arg in theArgs.elements)
    {
        [theArgNames addObject:arg.name];  
    }
    
    [fn setArgNames:[NSSet setWithSet:theArgNames]];
    [fn setArgsDefaultVals:theArgsDefaultVals];                            
    [fn setRestArg:theRestArg];
    return [fn autorelease];
}

+ (CacaoFn *)fnWithDispatchFunction:(DispatchFunction)theFunc args:(CacaoVector *)theArgs 
                            restArg:(CacaoSymbol *)theRestArg;
{
    return [CacaoFn fnWithDispatchFunction:theFunc args:theArgs argsDefaults:nil restArg:theRestArg];
}

+ (CacaoFn *)fnWithDispatchFunction:(DispatchFunction)theFunc restArg:(CacaoSymbol *)theRestArg
{
    return [CacaoFn fnWithDispatchFunction:theFunc args:nil argsDefaults:nil restArg:theRestArg];
}

- (NSString *)printable
{
    return identity;    
}


- (id)invokeWithArgsAndVals:(NSArray *)argsAndVals
{
    BOOL invokeSignatureCorrect = NO;
    NSMutableDictionary * av = [NSMutableDictionary dictionary];
    if (argsAndVals.count > 0)
    {
        if (argsAndVals.count % 2 == 0)            
        {
            // If any args were not specified in the function invocation, and they have default values,
            // add them to the argsAndVals array.
            __block NSMutableArray * argDefaults = [NSMutableArray array];
            [self.argsDefaultVals enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (![argsAndVals containsObject:key])
                {
                    CacaoArgumentName * argName = [CacaoArgumentName argumentNameInternedFromSymbol:key];                    
                    [argDefaults addObject:argName];
                    [argDefaults addObject:obj];
                }
            }];
            if ([argDefaults count] > 0)
                argsAndVals = [argsAndVals arrayByAddingObjectsFromArray:argDefaults];
            
            
            // Check that all required arguments have been specified, and add them and their values
            // to the dictionary that is passed to the function
            
            NSUInteger pairCount = [argsAndVals count]/2;
            // A function can either be invoked with or without its REST arguments (they're optional and of
            // unspecified length. So at a minimum the named arguments must be passed to the invocation, 
            // and potentially an additional pair might be included, reflecting the REST argument name & value.
            if ((pairCount >=  self.argNames.count) && (pairCount <= self.argNames.count + 1))
            {                
                invokeSignatureCorrect = YES;

                for (NSUInteger i=0; i < pairCount; i++) {
                    NSUInteger argIndex = i*2;
                    NSUInteger valIndex = argIndex + 1;
                    CacaoSymbol * argNameSym = [(CacaoArgumentName *)[argsAndVals objectAtIndex:argIndex] symbol];
                    if (![self.argNames containsObject:argNameSym.name] && ![restArg isEqual:argNameSym])
                    {
                        invokeSignatureCorrect = NO;
                        break;
                    }
                    NSObject * argVal = [argsAndVals objectAtIndex:valIndex];
                    [av setObject:argVal forKey:argNameSym];
                }
            }
        }        
    }
    if (invokeSignatureCorrect)
        return func(av);
    else 
    {
        NSMutableString * correctInvocation = [NSMutableString stringWithFormat:@"Specify each argument, e.g. (fnsym "];
        for (NSString * aName in self.argNames)
            [correctInvocation appendFormat:@"%@:... ", aName];
        [correctInvocation appendString:@")"];
        @throw [NSException exceptionWithName:@"Incorrect CacaoFn invocation"
                                       reason:correctInvocation
                                     userInfo:nil];
    }

}

@end
