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
#import "CacaoSymbol.h"
#import "CacaoArgumentName.h"
#import "CacaoKeyword.h"
#import "CacaoBigInteger.h"
#import "BigInteger.h"
#import "BigDecimal.h"
#import "GMPRational.h"
#import "RegexKitLite.h"

// Reader Macros
#import "CacaoReaderMacroInvokers.h"

unichar CACAO_READER_STRING_CHAR = (unichar)'"';
unichar CACAO_READER_LIST_START_CHAR = (unichar)'<';
unichar CACAO_READER_LIST_END_CHAR = (unichar)'|';
unichar CACAO_READER_LIST_COLLAPSE_CHAR = (unichar)']';
NSString * CACAO_READER_LIST_COLLAPSE_STRING = @"]";
unichar CACAO_READER_VECTOR_START_CHAR = (unichar)'(';
unichar CACAO_READER_VECTOR_END_CHAR = (unichar)')';

static unichar CACAO_READER_ARG_VAL_SEPARATOR = (unichar)':';
static NSString * CACAO_ARG_VAL_SEPARATOR_STRING = @":";
static NSString * CACAO_READER_KEYWORD_PREFIX = @":";

static NSDictionary * readerMacros = nil;
static NSCharacterSet * additionalWhitespaceCharacterSet = nil;


@implementation CacaoLispReader

#pragma mark Setup

+ (void)initialize
{                
    readerMacros = [NSDictionary dictionaryWithObjectsAndKeys:
                    cacaoStringReaderMacro,                 [NSNumber numberWithUnsignedShort:(unichar)CACAO_READER_STRING_CHAR],
                    cacaoListReaderMacro,                   [NSNumber numberWithUnsignedShort:(unichar)CACAO_READER_LIST_START_CHAR],
                    cacaoUnmatchedDelimiterReaderMacro,     [NSNumber numberWithUnsignedShort:(unichar)CACAO_READER_LIST_END_CHAR],
                    cacaoVectorReaderMacro,                 [NSNumber numberWithUnsignedShort:(unichar)CACAO_READER_VECTOR_START_CHAR],
                    cacaoUnmatchedDelimiterReaderMacro,     [NSNumber numberWithUnsignedShort:(unichar)CACAO_READER_VECTOR_END_CHAR],
                     nil];
    
    additionalWhitespaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@","];
}

+ (ReaderMacro)readerMacroForChar:(unichar)macroChar
{
    ReaderMacro macroDispatcher = nil;
    macroDispatcher = [readerMacros objectForKey:[NSNumber numberWithUnsignedShort:macroChar]];
    return macroDispatcher;
}


#pragma mark Character checks

+ (BOOL)isWhiteSpace:(unichar)ch
{
    if (ch == 127 || [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch] ||
        [additionalWhitespaceCharacterSet characterIsMember:ch])
        return YES;
    else
        return NO;
}

+ (BOOL)isMacro:(unichar)ch
{
    return [CacaoLispReader readerMacroForChar:ch] != nil;
}

+ (BOOL)isTerminatingMacro:(unichar)ch
{
    return ((ch != '#') && [CacaoLispReader isMacro:ch]);
}



#pragma mark Symbols
+ (id)matchSymbol:(NSString *)token
{    
    NSArray * matches = nil;
    matches = [token captureComponentsMatchedByRegex:symbolPat];
    if (matches != nil)
    {
        NSString * ns = nil;       
        NSString * name = nil;  
        ns = [matches objectAtIndex:1];
        name = [matches objectAtIndex:2];
        
        bool isArgumentName = [token hasSuffix:CACAO_ARG_VAL_SEPARATOR_STRING];
        if (isArgumentName)
        {
            CacaoSymbol * sym = [CacaoSymbol internSymbol:[name substringToIndex:name.length-1]
                                              inNamespace:ns];
            return [CacaoArgumentName argumentNameInternedFromSymbol:sym];
        }
        
        CacaoSymbol * sym = [CacaoSymbol internSymbol:name inNamespace:ns]; 
        bool isKeyword = [token hasPrefix:CACAO_READER_KEYWORD_PREFIX];

        if (isKeyword)
            return [CacaoKeyword keywordInternedFromSymbol:sym];
        
        
        return sym;        
    }    
    return nil;
}



+ (id)interpretToken:(NSString *)token
{
    if ([token isEqualToString:@"nil"])
        return nil;
    else if ([token isEqualToString:@"YES"])
    {
        BOOL yes = YES;
        return [NSValue valueWithBytes:&yes objCType:@encode(BOOL)];
    }
    else if ([token isEqualToString:@"NO"])
    {
        BOOL no = NO;
        return [NSValue valueWithBytes:&no objCType:@encode(BOOL)];
    }
    
    id ret = nil;
    ret = [CacaoLispReader matchSymbol:token];
    if (ret != nil)
        return ret;
    
    @throw [NSException exceptionWithName:@"InvalidTokenException"
                                   reason:[NSString stringWithFormat:@"Invalid token: %@",token]
                                 userInfo:nil];      
}


+ (NSString *)readTokenFrom:(PushbackReader *)reader firstCharacter:(unichar)ch
{
    NSMutableString * token = [NSMutableString string];
    unichar charArray[1];
    charArray[0] = ch;
    [token appendString:[NSString stringWithCharacters:charArray length:1]];
    while (YES) {
        int nextChar = [reader read];
        if (nextChar == -1 || [CacaoLispReader isWhiteSpace:nextChar] || 
            [CacaoLispReader isTerminatingMacro:nextChar] ||
            nextChar == CACAO_READER_ARG_VAL_SEPARATOR || nextChar == CACAO_READER_LIST_COLLAPSE_CHAR)
        {
            BOOL tokenDone = YES;
            if (nextChar == CACAO_READER_ARG_VAL_SEPARATOR) 
            {
                if (token.length == 0)
                    tokenDone = NO;
                else
                    [token appendString:CACAO_ARG_VAL_SEPARATOR_STRING];
            }
            else 
            {
                [reader unreadSoThatNextCharIs:nextChar];
            }

            
            if (tokenDone)
            {
                
                return token;
            }
        }
        charArray[0] = nextChar;
        [token appendString:[NSString stringWithCharacters:charArray length:1]];
    }    
}




#pragma mark Read numbers

+ (NSObject *)matchNumber:(NSString *)theString
{
	// Use regex instead of Cocoa's NSScanner, because the latter
	// has numeric semantics different from what we want
	
	NSRange		searchRange		= NSMakeRange(0, [theString length]);
	NSRange		matchedRange;
	NSError		*error			= nil;
		
	matchedRange = [theString rangeOfRegex:intPat options:RKLNoOptions inRange:searchRange capture:0 error:&error];
	if (matchedRange.length == searchRange.length)
	{
		if ([theString stringByMatching:intPat capture:2] != nil)
            return [CacaoBigInteger bigIntegerFromText:@"0"];
		
        NSString * firstCharOfNumber = [theString stringByMatching:intPat capture:1];
		BOOL negate = [firstCharOfNumber isEqualToString:@"-"];
		NSString *n;
		int base = 10;
		if ((n = [theString stringByMatching:intPat capture:3]) != nil)
			base = 10;
		else if ((n = [theString stringByMatching:intPat capture:4]) != nil)
			base = 16;
		else if ((n = [theString stringByMatching:intPat capture:5]) != nil)
			base = 8;
		else if ((n = [theString stringByMatching:intPat capture:7]) != nil)
			base = [[theString stringByMatching:intPat capture:6] intValue];		
		if (n == nil)
			return nil;
        CacaoBigInteger *bn = [CacaoBigInteger bigIntegerFromText:n];
//		BigInteger *bn = [BigInteger bigIntegerWithValue:n base:base];
		if (negate) 
            [bn negate];
		return bn;			
	}
    
    matchedRange = [theString rangeOfRegex:ratioPat options:RKLNoOptions inRange:searchRange capture:0 error:&error];
	if (matchedRange.location != NSNotFound)
	{
		NSString *numerator = [theString stringByMatching:ratioPat capture:1];
		NSString *denominator = [theString stringByMatching:ratioPat capture:2];
		GMPRational *ratio = [GMPRational rationalWithValue:[numerator stringByAppendingFormat:@"/%@", denominator]];
		return ratio;
	}
	
	
	matchedRange = [theString rangeOfRegex:floatPat options:RKLNoOptions inRange:searchRange capture:0 error:&error];
	if (matchedRange.location != NSNotFound)
	{
		if ([[theString substringFromIndex:[theString length] -1] isEqualToString:@"M"])
			return [BigDecimal bigDecimalWithValue:theString];
		else
			return [NSNumber numberWithDouble:[theString doubleValue]];
	}
	
	return nil;
}


+ (id)readNumberFrom:(PushbackReader *)reader firstDigit:(int)digit
{
    NSMutableString * numberString = [NSMutableString string];
    unichar charArray[1];
    charArray[0] = digit;
    [numberString appendString:[NSString stringWithCharacters:charArray length:1]];
    
    while (YES) {
        int ch = [reader read];
        if (ch == -1 || [CacaoLispReader isWhiteSpace:ch] || [CacaoLispReader isMacro:ch])
        {
            [reader unreadSoThatNextCharIs:ch];
            break;
        }
        
        charArray[0] = ch;
        [numberString appendString:[NSString stringWithCharacters:charArray length:1]];
    }
    
    NSObject * theNumber = nil;
    theNumber = [CacaoLispReader matchNumber:numberString];
    if (theNumber == nil)
        @throw [NSException exceptionWithName:@"NumberFormatException" 
                                       reason:[NSString stringWithFormat:@"Invalid number: %s", numberString]
                                     userInfo:nil];
    return theNumber;
}


#pragma mark Entry point

+ (id)readFrom:(PushbackReader *)reader eofValue:(NSObject *)eofValue
{
    do {        
        unichar ch = [reader read];
        
        while ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:ch])
            ch = [reader read];
        
        if (ch == -1)
            return eofValue;
        
        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch]) {
            id number = [CacaoLispReader readNumberFrom:reader firstDigit:ch];
            return number;
        }
        
        ReaderMacro macroDispatcher = [CacaoLispReader readerMacroForChar:ch];        
        if (macroDispatcher != nil) {
            NSObject * ret = macroDispatcher(reader, ch, nil);           
            if (ret == reader)
                continue;
            return ret;
        }      
        
//        if (ch == '+' || ch == '-')
//        {
//            unichar ch2 = [reader read];
//            if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch2])
//            {
//                id number = [CacaoLispReader readNumberFrom:reader firstDigit:ch];
//                return number;
//            }
//            [reader unreadSoThatNextCharIs:ch2];
//        }
        
        NSString * token = [CacaoLispReader readTokenFrom:reader firstCharacter:ch];
        return [CacaoLispReader interpretToken:token];
        
    } while (YES);
}


#pragma mark Support

+ (NSArray *)readListDelimitedWith:(char)delim 
                              from:(PushbackReader *)reader 
                collapseListOnChar:(char)collapseChar
          nestingIncreasesWithChar:(char)nestingChar
                      nestingDepth:(uint)initialNestingDepth
{
    NSMutableArray * theList = [NSMutableArray array];
    uint nestingDepth = initialNestingDepth;    
    BOOL collapsingMode = collapseChar != '\0';
    
    while (YES) {
        int ch = [reader read];
        while([CacaoLispReader isWhiteSpace:ch])
            ch = [reader read];
        
        if (ch == -1)
            @throw [NSException exceptionWithName:@"EOFException"
                                           reason:@"EOF while reading"
                                         userInfo:nil];      

        if (ch == delim || ch == 0)
            break;
        
        ReaderMacro macroDispatcher = [CacaoLispReader readerMacroForChar:ch];
        if (macroDispatcher != nil)
        {
            id macroRet = nil;
            
            if (collapsingMode && (ch == nestingChar))
            {
                nestingDepth++;
                macroRet = macroDispatcher(reader, ch, nestingDepth, nil);
            }
            else
                macroRet = macroDispatcher(reader, ch);

            // no op macros return the reader
            if (macroRet != reader)
                    [theList addObject:macroRet];                      
        }
        else if (collapsingMode && (ch == collapseChar))
        {
            // When encounter the collapse character, substitute it with the correct number of list delimiter
            // characters, so that nested expressions are all enclosed
            NSMutableArray * delimitersToCollapseList = [NSMutableArray arrayWithCapacity:nestingDepth];
            for (ushort i=0; i <= nestingDepth; i++) {
                [delimitersToCollapseList addObject:[NSNumber numberWithChar:delim]];                
            }
            [reader unreadSoThatNextCharsAre:delimitersToCollapseList];
        }
        else 
        {
            [reader unreadSoThatNextCharIs:ch];
            id nextItem = [CacaoLispReader readFrom:reader eofValue:nil];
            if (nextItem != reader)
                [theList addObject:nextItem];
        }        
    }
    
    return [NSArray arrayWithArray:theList];    
}

+ (NSArray *)readListDelimitedWith:(char)delim from:(PushbackReader *)reader
{
    return [CacaoLispReader readListDelimitedWith:delim
                                             from:reader
                               collapseListOnChar:'\0'
                         nestingIncreasesWithChar:'\0'
                                     nestingDepth:0];
}

@end
