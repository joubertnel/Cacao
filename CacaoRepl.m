//
//  CacaoRepl.m
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

#import "CacaoRepl.h"
#import "CacaoEnvironment.h"
#import <stdio.h>


#define MAX_LEN 1000

@implementation CacaoRepl

+ (void)displayWelcome
{   
    NSString * appName = @"Cacao";
    NSString * appVersion = @"0.0.1";
    NSString * copyright = @"Copyright © 2010, Joubert Nel";
    NSArray * messages = [NSArray arrayWithObjects:
                          @"\n",
                         appName, @" version ", appVersion, @"\n",
                         copyright, @"\n", nil];
    for (NSString * msg in messages)
        [msg writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

@end


int main(int argc, char* argv[])
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];    
    
    [CacaoRepl displayWelcome];
   
    char repl_input[MAX_LEN + 1];
    
    CacaoEnvironment * globalEnv = [CacaoEnvironment globalEnvironment];
    
    do {        
        @try 
        {
            NSString * cacaoReplInput = [NSString stringWithCString:repl_input encoding:NSUTF8StringEncoding];
            if ([cacaoReplInput length] > 0)
            {
                NSData * inputData = [cacaoReplInput dataUsingEncoding:NSUTF8StringEncoding];
                NSInputStream * stream = [NSInputStream inputStreamWithData:inputData];
                [stream open];
                PushbackReader * pushbackReader = [[PushbackReader alloc] init:stream];
                NSObject * readerOutput = [CacaoLispReader readFrom:pushbackReader eofValue:nil];
                NSObject * result = [CacaoEnvironment eval:readerOutput inEnvironment:globalEnv];
                [pushbackReader release];
                [stream close];
                 
                NSString * printable = @"";
                if ([result respondsToSelector:@selector(printable)])
                    printable = [result performSelector:@selector(printable)];
                [printable writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
            }
        }
        @catch (NSException * e) {            
            NSString * errorMessage = [NSString stringWithFormat:@"\n\n%@: %@\n\n Stacktrace:\n", [e name], [e reason]];
            [errorMessage writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
            [[e callStackSymbols] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString * stackTraceLine = [NSString stringWithFormat:@"%@\n", obj];
                [stackTraceLine writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
            }];
        }     
        @finally {
            [@"\n" writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
            NSString * prompt = [NSString stringWithFormat:@"%@ ? ", @""];
            [prompt writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
    } while (fgets(repl_input, MAX_LEN + 1, stdin));
    
    [pool drain];
}
