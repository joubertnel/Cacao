//
//  CacaoAST.m
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

#import "CacaoAST.h"


@implementation CacaoAST

@synthesize source;
@synthesize tokens;
@synthesize tree;

#pragma mark Making atoms


+ (NSString *)makeAtomForStringToken:(NSString *)token
{
    BOOL tokenRepresentsString = ([token hasPrefix:@"\""] && ([token hasSuffix:@"\""] || [token hasSuffix:@"\"\n"]));
   
    if (tokenRepresentsString)
    {
        NSRange valueBetweenQuotes;
        valueBetweenQuotes.location = 1;
        valueBetweenQuotes.length = [token length] - 2;
        if ([token hasSuffix:@"\n"])
        {
            valueBetweenQuotes.length--;
        }
        return [token substringWithRange:valueBetweenQuotes];
    }
    else return nil;
}

+ (NSNumber *)makeAtomForNumberToken:(NSString *)token
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * theNumber = [numberFormatter numberFromString:token];
    [numberFormatter release];
    return theNumber;
}

+ (id)atomFrom:(NSString *)token
{
    id theAtom = nil;
    theAtom = [CacaoAST makeAtomForStringToken:token];
    if (theAtom == nil)
    {
        theAtom = [CacaoAST makeAtomForNumberToken:token];
        if (theAtom == nil)
        {
            theAtom = [CacaoSymbol symbolWithName:token];
        }
    }    
    return theAtom;
}

#pragma mark Parsing

+ (id)readFrom:(NSMutableArray *)tokens
{
    if ([tokens count] == 0)
        [NSException raise:@"EOF" format:@"EOF"];

    NSString * token = [tokens objectAtIndex:0];
    [tokens removeObjectAtIndex:0];
    
    if ([token isEqualToString:@"("])
    {
        NSMutableArray * list = [NSMutableArray array];
        while (![[tokens objectAtIndex:0] isEqualToString:@")"])
        {               
            [list addObject:[CacaoAST readFrom:tokens]];
        }
        [tokens removeObjectAtIndex:0]; // remove ")"
        return [NSArray arrayWithArray:list];
    }
    else if ([token isEqualToString:@")"])
    {
        [NSException raise:@"unexpected" format:@"unexpected"];
        return nil;
    }
    else if ([token isEqualToString:@"nil"])
        return [CacaoNil nilObject];
    else if ([token isEqualToString:@"["])
    {
        NSMutableArray * vectorElements = [NSMutableArray array];
        while (![[tokens objectAtIndex:0] isEqualToString:@"]"])
        {
            [vectorElements addObject:[CacaoAST readFrom:tokens]];
        }
        [tokens removeObjectAtIndex:0]; // remove "]"
        return [CacaoVector vectorWithArray:vectorElements];
    }
    else return [CacaoAST atomFrom:token];

}


- (void)tokenize
{
    if ([source length] > 0)
    {
        NSString * spacedForLeftParen = [self.source stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
        NSString * spacedForParens = [spacedForLeftParen stringByReplacingOccurrencesOfString:@")" withString:@" ) "];   
        NSString * spacedForLeftBrackets = [spacedForParens stringByReplacingOccurrencesOfString:@"[" withString:@" [ "];
        NSString * spacedForBrackets = [spacedForLeftBrackets stringByReplacingOccurrencesOfString:@"]" withString:@" ] "];
        
        NSMutableArray * possibleTokens = [NSMutableArray arrayWithArray:[spacedForBrackets componentsSeparatedByString:@" "]];
        NSMutableArray * indexesOfEmptyTokens = [NSMutableArray array];
        
        [possibleTokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString * token = (NSString *)obj;
            BOOL emptyToken = [token length] == 0;
            BOOL newlineToken = [token isEqualToString:@"\n"];
            if (emptyToken || newlineToken)
                [indexesOfEmptyTokens addObject:[NSNumber numberWithInt:idx]];
                
        }];
        
        [indexesOfEmptyTokens enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            int emptyTokenIndex = [(NSNumber *)obj intValue];
            [possibleTokens removeObjectAtIndex:emptyTokenIndex];
        }];
        
        [self setTokens:possibleTokens];
    }
}

- (void)parse
{
    [self tokenize];
    NSMutableArray * tokensToProcess = [NSMutableArray arrayWithArray:self.tokens];
    [self setTree:[CacaoAST readFrom:tokensToProcess]];
}
                             

#pragma mark Life cycle

- (CacaoAST *)initWithText:(NSString *)theText
{
    if ((self = [super init]))
    {
        if ([theText hasSuffix:@"\n"])
            theText = [theText substringToIndex:(theText.length - 1)];
        [self setSource:theText];
        [self parse];
    }
    return self;
}

+ (CacaoAST *)astWithText:(NSString *)theText
{
    CacaoAST * ast = [[CacaoAST alloc] initWithText:theText];
    return [ast autorelease];
}

+ (CacaoAST *)astWithTokens:(NSArray *)theTokens
{
    
}

- (NSString *)toString
{
    return [self source];
}


#pragma mark Visualize


- (void)explore
{
    NSString * printable = [tree printableWithIndentation:CACAO_PRINTABLE_INDENTATION];
    [printable writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [@"\n" writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}






@end
