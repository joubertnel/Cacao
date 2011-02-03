//
//  CacaoVector.m
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

#import "CacaoVector.h"
#import "CacaoNil.h"

@implementation CacaoVector

@synthesize materializedItems = _materializedItems;
@synthesize itemsSet = _itemsSet;
@synthesize generator = _generator;
@synthesize isFullyMaterialized;


#pragma mark Life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setMaterializedItems:[NSMutableDictionary dictionary]];
        [self setItemsSet:[NSMutableSet set]];
    }
    return self;
}

+ (CacaoVector *)vectorWithFirstItem:(id)first subsequentGenerator:(LazyGenerator)theGenerator
{
    CacaoVector * vec = [[CacaoVector alloc] init];    
    [vec setObject:first atIndex:0];    
    [vec setGenerator:theGenerator];
    return [vec autorelease];
}

+ (CacaoVector *)vectorWithArray:(NSArray *)theElements
{
    __block CacaoVector * vec = [[CacaoVector alloc] init];
    
    [theElements enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {        
        [vec setObject:obj atIndex:idx];
    }];
    [vec setIsFullyMaterialized:YES];
    return [vec autorelease];
}

+ (CacaoVector *)vectorWithDictionary:(NSDictionary *)theIndexedElements
{
    CacaoVector * vec = [[CacaoVector alloc] init];
    [vec setMaterializedItems:[NSMutableDictionary dictionaryWithDictionary:theIndexedElements]];
    [vec setItemsSet:[NSMutableSet setWithArray:[theIndexedElements allValues]]];
    [vec setIsFullyMaterialized:YES];
    return [vec autorelease];
}

- (id)makeKeyForIndex:(NSUInteger)index
{
    return [NSValue valueWithBytes:&index objCType:@encode(NSUInteger)];
}


#pragma mark Laziness

- (void)materializeUpTo:(NSUInteger)targetIndex
{
    if (!isFullyMaterialized)
    {
        NSRange range = {.location=0, .length=targetIndex+1};
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        
        [indexSet enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop) {
            if (isFullyMaterialized)
            {
                *stop = YES;
            }
            else {
                [self objectAtIndex:idx];
            }        
        }];    
    }
}

- (void)setObject:(id)object atIndex:(NSUInteger)index
{
    [self.materializedItems setObject:object forKey:[self makeKeyForIndex:index]];
    [self.itemsSet addObject:object];
}


- (void)materializeAll
{
    if (!isFullyMaterialized)
    {        
        NSUInteger nextIndex = 0;
        BOOL stop = NO;
        while (stop == NO)
        {
            [self objectAtIndex:nextIndex];
            
            nextIndex++;
                
            if (self.isFullyMaterialized)
                stop = YES;
        }
    }
}

- (NSArray *)elements
{
    if (!isFullyMaterialized)
        [self materializeAll];
    
    return [self.materializedItems allValues];
}


- (NSUInteger)count
{
    if (!isFullyMaterialized)
        [self materializeAll];
    
    return [self.materializedItems count];
}

- (void)force
{
    [self materializeAll];
}

- (id)materializeObjectAtIndex:(NSUInteger)index
{
    BOOL reachedTheEnd = NO;
    id obj = _generator(index, &reachedTheEnd);
    
    if (reachedTheEnd)
        [self setIsFullyMaterialized:YES];

    if (obj)
    {
        [self setObject:obj atIndex:index];
        return obj;
    }

    return nil;
}

#pragma mark Other array-like behavior

- (id)objectAtIndex:(NSUInteger)index
{    
    id obj = [self.materializedItems objectForKey:[self makeKeyForIndex:index]];
    if (obj)
        return obj;
    
    // The object at index has not been materialized yet; do so now.
    return [self materializeObjectAtIndex:index];   
    
}

- (BOOL)containsObject:(id)object
{
    if (isFullyMaterialized)
    {
        return [self.itemsSet containsObject:object];
    }
    
    // If the vector is not fully materialized, systematically
    // materialize its contents, until we discover a match
    
    NSUInteger index = 0;
    while (YES)
    {
        if (self.isFullyMaterialized)
            return NO;
        
        id obj = [self objectAtIndex:index];
        if (obj == object)
            return YES;
        index++;
    }
    
    return NO;    
}

- (NSArray *)subarrayWithRange:(NSRange)range
{    
    NSUInteger lastIndex = range.location + range.length - 1;
    [self materializeUpTo:lastIndex];
    
    NSMutableArray * sortedKeys = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = range.location; i <= lastIndex; i++) {
        [sortedKeys addObject:[self makeKeyForIndex:i]];
    }
    
    return [self.materializedItems objectsForKeys:sortedKeys notFoundMarker:[CacaoNil nilObject]];
         
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[CacaoVector class]])
        return NO;
    
    CacaoVector * other = (CacaoVector *)object;
    
    if ([self isFullyMaterialized] && [other isFullyMaterialized])
    {
        return [self.materializedItems isEqualToDictionary:other.materializedItems];
    }
    
    // Both vectors are not fully materialized, so we systematically materialize
    // them until we hit a difference. If we materialize both fully without 
    // discovering a difference, then the two vectors are equal.
    
    BOOL areEqual = YES;
    NSUInteger index = 0;
    BOOL stop = NO;
    
    while (!stop) {        
        id thisObj = [self objectAtIndex:index];
        id otherObj = [other objectAtIndex:index];
        
        if (self.isFullyMaterialized || other.isFullyMaterialized)
            break;

        if (![thisObj isEqual:otherObj])
        {
            areEqual = NO;
            break;
        }
        index++;                    
    }
    
    if (self.isFullyMaterialized != other.isFullyMaterialized)
        areEqual = NO;
    
    return areEqual;
    
}



#pragma mark CacaoReadable protocol

- (NSString *)readableValue
{
    NSMutableString * readable = [NSMutableString string];    
    NSUInteger index = 0;    
    while (index < [self count]) 
    {
        id object = [self objectAtIndex:index];
        [readable appendFormat:@"%@ ", [object readableValue]];
        index++;
    }    
    return [NSString stringWithFormat:@"[%@]", readable];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CacaoVector: %@...", [[self objectAtIndex:0] readableValue]];
}


- (void)writeToFile:(NSString *)path
{
    [@"[" writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];

    
    NSUInteger nextIndex = 0;
    BOOL stop = NO;
    while (stop == NO) {
        
        id prevObj = [self objectAtIndex:nextIndex];
                
        if (prevObj) {
            [prevObj performSelector:@selector(writeToFile:) withObject:path];
            [@" " writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        
        nextIndex++;   
        
        if (self.isFullyMaterialized)
            if (nextIndex >= [self count])
                stop = YES;
    }            
    [@"]" writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

@end
