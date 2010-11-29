//
//  CCCons.h
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCPersistentMapProtocol.h"
#import "CCSeq.h"
#import "CCSeqProtocol.h"


@interface CCCons : CCSeq {
    
    NSObject * first;
    id <CCSeqProtocol> more;

}

@property (retain) NSObject * first;
@property (retain) id <CCSeqProtocol> more;

- (CCCons *)initWithMeta:(id <CCPersistentMapProtocol>)meta first:(NSObject*)theFirst more:(id <CCSeqProtocol>)theMore;
- (CCCons *)initWith:(NSObject *)theFirst more:(id <CCSeqProtocol>)themMore;
- (id <CCSeqProtocol>)next;
- (int)count;


@end
