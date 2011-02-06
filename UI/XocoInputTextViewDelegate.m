//
//  XocoInputTextViewDelegate.m
//
//  Created by Joubert Nel on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XocoInputTextViewDelegate.h"
#import "NSTextView+XocoOutput.h"
#import "XocoAppDelegate.h"

static const NSUInteger INDENTATION_WIDTH = 4;

@implementation XocoInputTextViewDelegate

- (NSUInteger)getNumberOfUnclosedOpenParens:(NSString *)aString
{
    NSUInteger openParenCount = [[aString componentsSeparatedByString:@"("] count] - 1;
    NSUInteger closeParenCount = [[aString componentsSeparatedByString:@")"] count] - 1;
    NSInteger count = openParenCount - closeParenCount;
    if (count < 0)
        return 0;
    else 
        return (NSUInteger)count;
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    if (commandSelector == @selector(insertNewline:))
    {
        NSUInteger indentLevel = [self getNumberOfUnclosedOpenParens:[aTextView string]];
        if (indentLevel == 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:XCEvalNotificationName object:nil];
        }
        else
        {
            NSString * indentation = [@"" stringByPaddingToLength:indentLevel*INDENTATION_WIDTH
                                                       withString:@" " 
                                                  startingAtIndex:0];
            [aTextView appendRegularString:[NSString stringWithFormat:@"\n%@", indentation]];
        }
        result = YES;
    }
    return result;
}

@end
