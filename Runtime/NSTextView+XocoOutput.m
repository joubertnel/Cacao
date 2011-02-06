//
//  NSMutableAttributedString+Xoco.m
//  Cacao
//
//  Created by Joubert Nel on 2/4/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import "NSTextView+XocoOutput.h"


@implementation NSTextView (XocoOutput)

- (void)appendRegularString:(NSString *)theString
{    
    NSAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:theString];
    [[self textStorage] appendAttributedString:attributedString];
    [attributedString release];
}

- (void)scrollToLastVisible
{
    [self appendRegularString:@"\n"];
    NSRange range = {.location=[[self textStorage] length], .length=0};
    [self scrollRangeToVisible:range];
}


@end
