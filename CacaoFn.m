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

+ (CacaoFn *)fnWithDispatchFunction:(DispatchFunction)theFunc;
{
    CacaoFn * fn = [[CacaoFn alloc] init];
    [fn setFunc:theFunc];
    return [fn autorelease];
}


- (NSString *)printable
{
    return identity;    
}


- (id)invokeWithArgsAndVals:(NSArray *)argsAndVals
{
    short pairCount = [argsAndVals count]/2;
    NSMutableDictionary * av = [NSMutableDictionary dictionaryWithCapacity:pairCount];
    for (int i=0; i <= pairCount; i = i + 2) {
        CacaoSymbol * arg = [(CacaoArgumentName *)[argsAndVals objectAtIndex:i] symbol];
        NSObject * argVal = [argsAndVals objectAtIndex:i+1];
        [av setObject:argVal forKey:arg];
    }
    return func(av);
}

@end
