/*
 *  untitled.h
 *  Cacao
 *
 *  Created by Joubert Nel on 12/18/10.
 *  Copyright 2010 Joubert Nel. All rights reserved.
 *
 */

#import "PushbackReader.h"
#import "CacaoLispReader.h"

typedef NSObject * (^ReaderMacro)(PushbackReader *reader, int firstCharacter);

ReaderMacro cacaoStringReaderMacro = ^(PushbackReader *reader, int firstCharacter) {
    NSMutableString * theString = [NSMutableString string];
    for (int ch = [reader read]; ch != '"'; ch = [reader read])
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

ReaderMacro cacaoListReaderMacro = ^(PushbackReader * reader, int firstCharacter) {
    NSArray * theList = [CacaoLispReader readListDelimitedWith:')' from:reader];
    return theList;
};

ReaderMacro cacaoUnmatchedDelimiterReaderMacro = ^(PushbackReader * reader, int firstCharacter) {
    @throw [NSException exceptionWithName:@"UnreadableFormException"
                                   reason:@"Unreadable form"
                                 userInfo:nil];
    id nothing = nil;
    return nothing;
};
