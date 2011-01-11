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


@implementation CacaoVector

@synthesize materializingItems;
@synthesize materializedItems;
@synthesize isFullyMaterialized;
@synthesize generator;



#pragma mark Life cycle

+ (CacaoVector *)vectorWithFirstItem:(id)first subsequentGenerator:(LazyGenerator)theGenerator
{
    CacaoVector * vec = [[CacaoVector alloc] init];
    [vec setMaterializingItems:[NSMutableArray arrayWithObject:first]];
    [vec setGenerator:theGenerator];
    return [vec autorelease];
}

+ (CacaoVector *)vectorWithArray:(NSArray *)theElements
{
    CacaoVector * vec = [[CacaoVector alloc] init];
    [vec setMaterializedItems:theElements];
    [vec setIsFullyMaterialized:YES];
    return [vec autorelease];
}


#pragma mark Laziness


- (void)materializeUpTo:(NSUInteger)targetIndex
{
    if (!isFullyMaterialized)
    {
        // materialize up to one element after the requested index, so that we can detect
        // whether the end of the lazy vector has been reached 
        targetIndex++;
        
        NSUInteger nextIndex = [materializingItems count];
        BOOL stop = NO;
        while ((targetIndex >= nextIndex) && (stop == NO)) {
            id prev = [materializingItems lastObject];
            id newObj = generator(prev, nextIndex, &stop);
            if (newObj != nil)
                [materializingItems addObject:newObj];
            
            if (stop)
            {
                [self setMaterializedItems:[NSArray arrayWithArray:materializingItems]];
                isFullyMaterialized = YES;
            }
            
            nextIndex++;                              
        }
    }
}

- (void)materializeAll
{
    if (!isFullyMaterialized)
    {
        NSUInteger nextIndex = [materializingItems count];
        BOOL stop = NO;
        while (stop == NO)
        {
            id newObj = generator(nil, nextIndex, &stop);
            if (newObj)
                [materializingItems addObject:newObj];
            
            if (stop)
            {
                [self setMaterializedItems:[NSArray arrayWithArray:materializingItems]];
                isFullyMaterialized = YES;
            }
            else {
                nextIndex++;
            }
        }
    }
}


- (NSArray *)elements
{
    if (!isFullyMaterialized)
        [self materializeAll];
    
    return materializedItems;
}


- (NSUInteger)count
{
    if (!isFullyMaterialized)
        [self materializeAll];
    
    return [materializedItems count];
}


#pragma mark Other array-like behavior

- (id)objectAtIndex:(NSUInteger)index
{
    if (isFullyMaterialized)
        return [materializedItems objectAtIndex:index];
    
    if (index >= [materializingItems count])
        [self materializeUpTo:index]; 
    
    return [materializingItems objectAtIndex:index];
}

- (BOOL)containsObject:(id)object
{
    if (isFullyMaterialized)
        return [self.materializedItems containsObject:object];
    
    // Test to see whether the array of intermediates 
    // contains the object. If not, we'll systematically
    // materialize the rest of the items until we find a match.
    
    BOOL isInIntermediates = [self.materializingItems containsObject:object];
    if (isInIntermediates)
        return YES;
    
    NSUInteger nextIndex = [materializingItems count];
    BOOL stop = NO;
    while (stop == NO)
    {
        id prev = [materializingItems lastObject];
        id newObj = generator(prev, nextIndex, &stop);
        if (newObj != nil)
            [materializingItems addObject:newObj];
        
        if (stop)
        {
            [self setMaterializedItems:[NSArray arrayWithArray:materializingItems]];
            isFullyMaterialized = YES;
        }
        
        if ([newObj isEqual:object])
            return YES;
        
        nextIndex++;
    }
    
    return NO;
}

- (NSArray *)subarrayWithRange:(NSRange)range
{
    NSUInteger index = range.location + range.length;
    if (isFullyMaterialized)
        return [materializedItems subarrayWithRange:range];
    else {
        [self materializeUpTo:index];
        return [materializingItems subarrayWithRange:range];
    }
}

- (void)writeToFile:(NSString *)path
{
    [@"[" writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    NSUInteger nextIndex = 0;
    BOOL stop = NO;
    while (stop == NO) {
        
        id prevObj = nil;
        id nextObj = nil;
        
        if (isFullyMaterialized)
        {
            if (nextIndex < [self count])
                prevObj = [materializedItems objectAtIndex:nextIndex];
            else
                stop = YES;
        } 
        else      
        {
            prevObj = [materializingItems lastObject];
            nextObj = generator(prevObj, nextIndex, &stop);
            if (nextObj)
                [materializingItems addObject:nextObj];
            
            if (stop)
            {
                isFullyMaterialized = YES;
                [self setMaterializedItems:[NSArray arrayWithArray:materializingItems]];
            } 
        }
              
        if (prevObj) {
            [prevObj performSelector:@selector(writeToFile:) withObject:path];
            [@" " writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        nextIndex++;        
    }
    
    [@"]" writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
}


- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[CacaoVector class]])
        return NO;
    
    CacaoVector * other = (CacaoVector *)object;
    
    if ([self isFullyMaterialized] && [other isFullyMaterialized])
    {
        return [self.materializedItems isEqual:other.materializedItems];
    }
    
    // First see whether there are differences in the intermediates that have already been materialized    
    NSUInteger thisVecItemCount = [self.materializingItems count];
    NSUInteger otherVecItemCount = [other.materializingItems count];
    NSUInteger maxCommonIndex = (thisVecItemCount >= otherVecItemCount) ? otherVecItemCount-1 : thisVecItemCount-1;
    
    
    NSRange commonRangeOfIntermediates = {.location=0, .length=maxCommonIndex+1};
    NSArray * thisVecIntermediatesToCompare = [self.materializingItems subarrayWithRange:commonRangeOfIntermediates];
    NSArray * otherVecIntermediatesToCompare = [other.materializingItems subarrayWithRange:commonRangeOfIntermediates];
    
    BOOL areIntermediatesEqual = [thisVecIntermediatesToCompare isEqual:otherVecIntermediatesToCompare];
    if (!areIntermediatesEqual)
        return NO;
    
    // So far, the materialized items of the two vectors are the same, now evaluate the remaining items
    // lazily until we hit a difference. If we have fully materialized both vectors without hitting
    // differences, the two vectors are equal.
 
    NSUInteger nextIndex = maxCommonIndex + 1;
    BOOL vecsAreEqual = YES;
    while (vecsAreEqual) {
      
        @try {
            [self materializeUpTo:nextIndex];
        }
        @catch (NSException *e) {}
        
        @try {
            [other materializeUpTo:nextIndex];
        }
        @catch (NSException * e) {}        

        vecsAreEqual = [[self objectAtIndex:nextIndex] isEqualTo:[other objectAtIndex:nextIndex]];
        
        if (self.isFullyMaterialized != other.isFullyMaterialized)
            vecsAreEqual = NO;
        else 
        {
            if (self.isFullyMaterialized && other.isFullyMaterialized)
                break;
            
             nextIndex++;
        }  
      }
    return vecsAreEqual;    
}

@end
