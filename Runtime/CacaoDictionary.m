//
//  CacaoDictionary.m
//  Cacao
//
//    Copyright 2011, Joubert Nel. All rights reserved.
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

#import "CacaoDictionary.h"
#import "NSArray+Functional.h"
#import "NSTextView+XocoOutput.h"

const NSString * CACAO_DICT_START_CHAR = @"{";
const NSString * CACAO_DICT_END_CHAR = @"}";

@implementation CacaoDictionary

@synthesize elements;

+ (CacaoDictionary *)dictionaryWithNSDictionary:(NSDictionary *)theElements
{
    CacaoDictionary * dict = [[CacaoDictionary alloc] init];
    [dict setElements:theElements];
    return [dict autorelease];
}

+ (CacaoDictionary *)dictionaryWithKeyValueArray:(NSArray *)keysAndValues
{
    CacaoDictionary * dict = [[CacaoDictionary alloc] init];
    [dict setElements:[keysAndValues dictionaryFromKeysAndValues]];    
    return [dict autorelease];
}


- (void)printToTextView:(NSTextView *)target
{
    [target appendRegularString:[self readableValue]];
}


- (NSString *)readableValue
{
    __block NSMutableString * kvPairs = [NSMutableString string];
    [self.elements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [kvPairs appendFormat:@"%@ %@ ", [key readableValue], [obj readableValue]];
    }];
    return [NSString stringWithFormat:@"%@ %@ %@", CACAO_DICT_START_CHAR, kvPairs, CACAO_DICT_END_CHAR];
}

@end
