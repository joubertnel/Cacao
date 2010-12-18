//
// CacaoReaderMacroInvokers.h
// Cacao
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

#import "PushbackReader.h"
#import "CacaoLispReader.h"

typedef NSObject * (^ReaderMacro)(PushbackReader *reader, unichar firstCharacter);

ReaderMacro cacaoStringReaderMacro = ^(PushbackReader *reader, unichar firstCharacter) {
    NSMutableString * theString = [NSMutableString string];
    for (unichar ch = [reader read]; ch != '"'; ch = [reader read])
    {
        if (ch == -1)
            @throw [NSException exceptionWithName:@"EOFException"
                                           reason:@"EOF while reading string"
                                         userInfo:nil];
        
        if (ch == '\\')
        {
            ch = [reader read];
            
            if (ch == -1)
                @throw [NSException exceptionWithName:@"EOFException"
                                               reason:@"EOF while reading string"
                                             userInfo:nil];
            switch (ch) {
                case 't':
                    ch = '\t';
                    break;
                case 'r':
                    ch = '\r';
                    break;
                case 'n':
                    ch = '\n';
                    break;
                case '\\':
                    break;
                case '"':
                    break;
                case 'b':
                    ch = '\b';
                    break;
                case 'f':
                    ch = '\f';
                    break;
                default:
                    break;
            }
        }
        
        unichar charArray[1];
        charArray[0] = ch;
        [theString appendString:[NSString stringWithCharacters:charArray
                                                        length:1]];        
    }
    
    return theString;       
};

ReaderMacro cacaoListReaderMacro = ^(PushbackReader * reader, unichar firstCharacter) {
    NSArray * theList = [CacaoLispReader readListDelimitedWith:')' from:reader];
    return theList;
};

ReaderMacro cacaoUnmatchedDelimiterReaderMacro = ^(PushbackReader * reader, unichar firstCharacter) {
    @throw [NSException exceptionWithName:@"UnreadableFormException"
                                   reason:@"Unreadable form"
                                 userInfo:nil];
    id nothing = nil;
    return nothing;
};
