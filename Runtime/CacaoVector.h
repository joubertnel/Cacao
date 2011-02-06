//
//  CacaoVector.h
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

#import <Foundation/Foundation.h>
#import "CacaoReadable.h"


typedef NSObject * (^LazyGenerator)(NSUInteger index, BOOL *stop);


@interface CacaoVector : NSObject <CacaoReadable> {
    BOOL isFullyMaterialized;
    
@private
    NSMutableDictionary * _materializedItems;
    NSMutableSet * _itemsSet;
    LazyGenerator _generator;    
}


@property (nonatomic, retain) NSMutableDictionary * materializedItems;
@property (nonatomic, retain) NSMutableSet * itemsSet;
@property (copy) LazyGenerator generator;
@property (nonatomic, assign) BOOL isFullyMaterialized;


+ (CacaoVector *)vectorWithFirstItem:(id)first subsequentGenerator:(LazyGenerator)generator;
+ (CacaoVector *)vectorWithArray:(NSArray *)theElements;
+ (CacaoVector *)vectorWithDictionary:(NSDictionary *)theIndexedElements;


- (void)setObject:(id)object atIndex:(NSUInteger)index;
- (NSArray *)elements;
- (NSUInteger)count;
- (void)force;
- (id)objectAtIndex:(NSUInteger)index;
- (BOOL)containsObject:(id)object;
- (NSArray *)subarrayWithRange:(NSRange)range;
- (BOOL)isEqual:(id)object;

#pragma mark CacaoReadable protocol
- (NSString *)readableValue;
- (NSString *)description;
- (void)printToTextView:(NSTextView *)target;



@end
