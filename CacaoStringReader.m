//
//  CacaoStringReader.m
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

#import "CacaoStringReader.h"


@implementation CacaoStringReader

- (id)invokeOn:(NSInputStream *)theStream withCharacter:(NSString *)theCharacter
{
    NSMutableString * theString = [NSMutableString string];
    uint8_t theChar;
    while ([theStream hasBytesAvailable])
    {
        int numberOfCharsRead = [theStream read:&theChar maxLength:1];
        if ((numberOfCharsRead > 0) && (theChar != '"'))
        {
            if (theChar == '\\')
            {
                numberOfCharsRead = [theStream read:&theChar maxLength:1];
                if (theChar == -1)
                    @throw [NSException exceptionWithName:@"EOFException"
                                                   reason:@"End-of-file marker reached"
                                                 userInfo:nil];
                switch (theChar) {
                    case 't':
                        theChar = '\t';
                        break;
                    case 'r':
                        theChar = '\r';
                        break;
                    case 'n':
                        theChar = '\n';
                        break;
                    case '\\':
                        break;
                    case '"':
                        break;
                    case 'b':
                        theChar = '\b';
                        break;
                    case 'f':
                        theChar = '\f';
                        break;
                    default:
                        break;
                }
                
            }
            
            unichar charArray[1];
            charArray[0] = theChar;
            [theString appendString:[NSString stringWithCharacters:charArray
                                                            length:1]];
        }
    }
    
    return theString;
}

@end
