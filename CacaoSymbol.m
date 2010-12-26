//
//  CacaoSymbol.m
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

#import "CacaoSymbol.h"
#import "CacaoUtil.h"

static NSMutableDictionary * table = nil;

@implementation CacaoSymbol

@synthesize name;
@synthesize ns;
@synthesize cacaoHash;

#pragma mark Lifecycle

+ (void)initialize
{
    table = [NSMutableDictionary dictionary];
}

+ (CacaoSymbol *)symbolWithName:(NSString *)theName inNamespace:(NSString *)theNamespace
{  
    CacaoSymbol * existingSymbolInTable = nil;
    if (theNamespace == nil)
        theNamespace = @"";
    NSString * qualifiedName = [NSString stringWithFormat:@"%@/%@", theNamespace, theName];
    existingSymbolInTable = [table objectForKey:qualifiedName];
    if (existingSymbolInTable != nil)
        return existingSymbolInTable;
    else {
        CacaoSymbol * symbol = [[CacaoSymbol alloc] init];
        [symbol setName:theName];
        [symbol setNs:theNamespace];
        [symbol setCacaoHash:[CacaoUtil hashFromHash:[theNamespace hash] withSeed:[theName hash]]];
        [table setObject:symbol forKey:qualifiedName];
        return [symbol autorelease];
    }
}

+ (CacaoSymbol *)internSymbol:(NSString *)theName inNamespace:(NSString *)theNamespace
{
    return [CacaoSymbol symbolWithName:theName inNamespace:theNamespace];
}


#pragma mark Support

- (NSUInteger)hash
{
    return [self cacaoHash];
}

- (BOOL)isEqualToSymbol:(CacaoSymbol *)otherSymbol
{
    return [self.name isEqualToString:otherSymbol.name] && [self.ns isEqualToString:otherSymbol.ns];                                                   
            
}

- (NSString *)stringValue
{
    return self.name;
}

- (NSString *)printable
{
    return [self stringValue];
}

- (id)copyWithZone:(NSZone *)zone
{
    CacaoSymbol * aCopy = [CacaoSymbol symbolWithName:[self name] inNamespace:[self ns]];
    return [aCopy retain];
}


@end
