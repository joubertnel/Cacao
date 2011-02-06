//
//  XocoAppDelegate.m
//  Cacao
//
//  Created by Joubert Nel on 2/3/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import "XocoAppDelegate.h"
#import "CacaoEnvironment.h"
#import "CacaoLispReader.h"
#import "PushbackReader.h"
#import "XCMemorable.h"
#import "NSTextView+XocoOutput.h"


NSString * XCEvalNotificationName = @"XCEvalNotificationName";
CacaoEnvironment * globalEnv;

@implementation XocoAppDelegate

@synthesize window;
@synthesize cacaoMemory;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    globalEnv = [CacaoEnvironment globalEnvironment];
    [self.window makeFirstResponder:inputView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(evalNotification:) 
                                                 name:XCEvalNotificationName 
                                               object:nil];
    
}

- (void)appendToOutput:(NSString *)theText
{
    NSRange endRange = {.location=[[outputView textStorage] length], .length=0};
    [outputView replaceCharactersInRange:endRange withString:theText];
}

- (NSString *)makeFormattedInputText:(NSString *)inputText
{
    return [NSString stringWithFormat:@"? %@\n", inputText];
}

- (NSString *)makeFormattedOutputText:(NSString *)outputText
{
    return [NSString stringWithFormat:@"%@\n", outputText];
}


- (void)evalNotification:(NSNotification *)aNotification
{
    NSString * inputText = [inputView string];
    BOOL isInputTextNonBlank = [[inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
    if (isInputTextNonBlank)
    {
        [outputView appendRegularString:[self makeFormattedInputText:inputText]];
        
        NSInputStream * inputStream;
        PushbackReader * reader;
        
        @try {
            NSData * data = [inputText dataUsingEncoding:NSUTF8StringEncoding];
            inputStream = [NSInputStream inputStreamWithData:data];
            [inputStream open];
            
            reader = [[PushbackReader alloc] init:inputStream];
            NSObject * readerOutput = [CacaoLispReader readFrom:reader eofValue:nil];
            NSObject * result = [CacaoEnvironment eval:readerOutput inEnvironment:globalEnv];
            
            if ([result respondsToSelector:@selector(printToTextView:)])
            {
                [result performSelector:@selector(printToTextView:) withObject:outputView];             
            }
        }
        @catch (NSException * e) {
            NSString * errorMessage = [NSString stringWithFormat:@"\n\n%@: %@\n\n", [e name], [e reason]];
            NSDictionary * errorMessageAttribs = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSColor redColor], NSForegroundColorAttributeName, nil];
            NSAttributedString * attributedErrorMessage = [[NSAttributedString alloc] initWithString:errorMessage
                                                                                          attributes:errorMessageAttribs];
            [[outputView textStorage] appendAttributedString:attributedErrorMessage];
            [attributedErrorMessage release];

            // Print Xoco/Cacao-specific stacktrace (filter out Cocoa/Foundation items)
            [outputView appendRegularString:@"Stacktrace:\n"];
            NSUInteger stackTraceCounter = 0;
            NSString * stackTracePrefixForApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
            for (NSString * callStackSym in [e callStackSymbols])
            {
                NSRange xocoRange = [callStackSym rangeOfString:stackTracePrefixForApp];
                if (xocoRange.location != NSNotFound)
                {
                    NSString * stackTraceLine = [NSString stringWithFormat:@"%qu %@\n", 
                                                 stackTraceCounter,
                                                 [callStackSym substringFromIndex:xocoRange.location]];
                    [outputView appendRegularString:stackTraceLine];
                    stackTraceCounter++;
                }
            }
        }
        @finally {
            [inputStream close];
            [reader release];
        }        
        
        [outputView scrollToLastVisible];
    }
    [inputView setString:@""];    
    [window makeFirstResponder:inputView];    
    [inputView setNeedsDisplay:YES];
}



@end
