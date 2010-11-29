//
//  CCSeq.h
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCons.h"
#import "CCCounted.h"
#import "CCRT.h"
#import "CCSeqProtocol.h"

@interface CCSeq : NSObject <CCSeqProtocol> {

}

- (int)count;
- (id <CCSeqProtocol>)seq;
- (id <CCSeqProtocol>)cons:(NSObject *)theObject;
- (id <CCSeqProtocol>)more;
- (NSArray *)toArray;
- (bool)containsAll:(NSArray *)theObjects;
- (int)size;
- (bool)isEmpty;
- (bool)contains:(NSObject *)theObject;


# pragma mark List messages
- (NSArray *)reify;
- (NSArray *)subListFrom:(int)startIndex to:(int)endIndex;
- (int)indexOf:(NSObject *)theObject;
- (int)lastIndexOf:(NSObject *)theObject;
- (id)get:(int)index;


@end
