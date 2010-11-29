//
//  CacaoRepl.m
//  Cacao
//
//  Created by Joubert Nel on 11/13/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import "CacaoRepl.h"
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

    CacaoEnvironment * globalEnvironment = [CacaoEnvironment globalEnvironment];
    
    char repl_input[MAX_LEN + 1];
    
    do {        
        @try 
        {
            NSString * cacaoReplInput = [NSString stringWithCString:repl_input encoding:NSUTF8StringEncoding];
            if ([cacaoReplInput length] > 0)
            {
                CacaoAST *ast = [[CacaoAST alloc] initWithText:cacaoReplInput];
                NSObject * result = [CacaoEnvironment eval:ast.tree inEnvironment:globalEnvironment];                    
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
            NSString * prompt = [NSString stringWithFormat:@"%@ > ", @""];
            [prompt writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
    } while (fgets(repl_input, MAX_LEN + 1, stdin));
    
    [pool drain];
}
