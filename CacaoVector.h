//
//  CacaoVector.h
//  Cacao
//
//  Created by Joubert Nel on 11/14/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CacaoVector : NSObject {
    NSArray * elements;

}

@property (nonatomic, retain) NSArray * elements;

+ (CacaoVector *)vectorWithArray:(NSArray *)theElements;


- (NSString *)printable;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;


@end
