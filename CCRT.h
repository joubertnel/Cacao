//
//  CCRT.h
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCRT : NSObject {

}

+ (NSArray *)arrayFromSeq:(id <CCSeqProtocol>)theSeq;
+ (int)length:(id <CCSeqProtocol>)theSeq;

@end
