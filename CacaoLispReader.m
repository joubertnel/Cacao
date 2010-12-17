//
//  CacaoLispReader.m
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

#import "CacaoLispReader.h"
#import "CacaoStringReader.h"

static NSDictionary * macroDispatch = nil;


@implementation CacaoLispReader


+ (void)initialize
{
    macroDispatch = [NSDictionary dictionaryWithObjectsAndKeys:
                     [[CacaoStringReader alloc] init], @"\"",
                     nil];
}

+ (id)readFrom:(PushbackReader *)reader eofValue:(NSObject *)eofValue
{
    do {        
        int ch = [reader read];
        
        while ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:ch])
            ch = [reader read];
        
        if (ch == -1)
            return eofValue;
        
        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch]) {
            id number = [CacaoLispReader readNumberFrom:reader firstDigit:ch];
            return number;
        }
        
        unichar theCharArray[1];
        theCharArray[0] = ch;
        NSString * theCharAsString = [NSString stringWithCharacters:theCharArray length:1];
        NSString * macroDispatcher = nil;
        macroDispatcher = [macroDispatch objectForKey:theCharAsString];
        if (macroDispatcher) {
            id ret = [macroDispatcher performSelector:@selector(invokeOn:withCharacter:)
                                           withObject:[reader stream]
                                           withObject:theCharAsString];
                                           
            if (ret == reader)
                continue;
            return ret;
        }      
            
    } while (YES);
}

+ (id)readNumberFrom:(PushbackReader *)reader firstDigit:(int)digit
{
    return nil;
}

@end
