//
//  CacaoLispReader.h
//  Cacao
//
//    Copyright 2010, 2011, Joubert Nel. All rights reserved.
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

#import <Cocoa/Cocoa.h>
#import "PushbackReader.h"

#define symbolPat   @"[:]*?([\\D]*/)?([\\D][^/]*)"
#define intPat		@"([-+]?)(?:(0)|([1-9][0-9]*)|0[xX]([0-9A-Fa-f]+)|0([0-7]+)|([1-9][0-9]?)[rR]([0-9A-Za-z]+)|0[0-9]+)\\.?"   
#define ratioPat	@"([-+]?[0-9]+)/([0-9]+)"
#define floatPat	@"[-+]?[0-9]+(\\.[0-9]+)?([eE][-+]?[0-9]+)?[M]?"

extern unichar CACAO_READER_STRING_CHAR;
extern unichar CACAO_READER_LIST_START_CHAR;
extern unichar CACAO_READER_LIST_END_CHAR;
extern unichar CACAO_READER_LIST_COLLAPSE_CHAR;
extern NSString * CACAO_READER_LIST_COLLAPSE_STRING;
extern unichar CACAO_READER_VECTOR_START_CHAR;
extern unichar CACAO_READER_VECTOR_END_CHAR;
extern unichar CACAO_READER_DICT_START_CHAR;
extern unichar CACAO_READER_DICT_END_CHAR;
extern unichar CACAO_READER_QUOTE_CHAR;

@interface CacaoLispReader : NSObject {

}

+ (id)interpretToken:(NSString *)token;
+ (NSString *)readTokenFrom:(PushbackReader *)reader firstCharacter:(unichar)ch;
+ (id)readFrom:(PushbackReader *)reader eofValue:(NSObject *)eofValue;

+ (NSArray *)readListDelimitedWith:(char)delim 
                              from:(PushbackReader *)reader 
                collapseListOnChar:(char)collapseChar
          nestingIncreasesWithChar:(char)nestingChar
                      nestingDepth:(uint)initialNestingDepth;

+ (NSArray *)readListDelimitedWith:(char)delim from:(PushbackReader *)reader;
+ (BOOL)isWhiteSpace:(unichar)ch;

@end
