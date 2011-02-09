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
static CacaoEnvironment * globalEnv;

// We use a dictionary to keep track of memory tree category tree nodes
static NSString * memoryTreeFunctionsNodeKey = @"memoryTreeCategoryFunctions";
static NSString * memoryTreeVarsNodeKey = @"memory2TreeCategoryVars";
static NSDictionary * memoryTreeCategoryNodes;


@implementation XocoAppDelegate

@synthesize window;
@synthesize cacaoMemoryTreeController;


#pragma mark Utilities

- (void)buildMemoryBrowserCategories
{
    // Functions Node
    NSTreeNode * fnsTreeNode = [XCMemorable treeNodeWithDescription:@"Functions" userInfo:nil];
    [cacaoMemoryTreeController addObject:fnsTreeNode];
    
    // Vars Node
    NSTreeNode * varsTreeNode = [XCMemorable treeNodeWithDescription:@"Vars" userInfo:nil];
    [cacaoMemoryTreeController addObject:varsTreeNode];
    
    memoryTreeCategoryNodes = [NSDictionary dictionaryWithObjectsAndKeys:
                            fnsTreeNode, memoryTreeFunctionsNodeKey,
                            varsTreeNode, memoryTreeVarsNodeKey, nil];
}


- (void)appendToOutput:(NSString *)theText
{
//    NSRange endRange = {.location=[[outputView textStorage] length], .length=0};
//    [outputView replaceCharactersInRange:endRange withString:theText];
}

- (NSString *)makeFormattedInputText:(NSString *)inputText
{
    return [NSString stringWithFormat:@"? %@\n", inputText];
}


#pragma mark Life Cycle

- (void)dealloc
{
    [memoryTreeCategoryNodes release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    globalEnv = [CacaoEnvironment globalEnvironment];
    [self buildMemoryBrowserCategories];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(evalNotification:) 
                                                 name:XCEvalNotificationName 
                                               object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newDefVarNotification:) 
                                                 name:CacaoNewDefVarNotificationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newDefFunctionNotification:) 
                                                 name:CacaoNewDefFunctionNotificationName
                                               object:nil];
    
    [self.window makeFirstResponder:inputView];
}



#pragma mark Notification Processing

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

- (void)newDefVarNotification:(NSNotification *)aNotification
{
    CacaoSymbol * varSymbolName = [[aNotification userInfo] valueForKey:CacaoNewDefNotificationVarSymbolNameKey];
    
    NSTreeNode * varBrowsable = [XCMemorable treeNodeWithDescription:[varSymbolName name] userInfo:nil];
    NSTreeNode * varsCategory = [memoryTreeCategoryNodes valueForKey:memoryTreeVarsNodeKey];
    [[varsCategory mutableChildNodes] addObject:varBrowsable];
    [cacaoMemoryTreeController rearrangeObjects];
}

- (void)newDefFunctionNotification:(NSNotification *)aNotification
{    
    CacaoSymbol * fnSymbolName = [[aNotification userInfo] valueForKey:CacaoNewDefNotificationVarSymbolNameKey];
    NSTreeNode * fnBrowsable = [XCMemorable treeNodeWithDescription:[fnSymbolName name]
                                                           userInfo:nil];
    NSTreeNode * functionsCategory = [memoryTreeCategoryNodes valueForKey:memoryTreeFunctionsNodeKey];
    [[functionsCategory mutableChildNodes] addObject:fnBrowsable];  
    [cacaoMemoryTreeController rearrangeObjects];
}



@end
