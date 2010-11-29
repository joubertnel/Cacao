//
//  CacaoFn.h
//  Cacao
//
//  Created by Joubert Nel on 11/22/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CacaoVector.h"

typedef NSObject * (^DispatchFunction)(NSArray * params);

@interface CacaoFn : NSObject {
    DispatchFunction func;
}

@property (copy) DispatchFunction func;

+ (CacaoFn *)fnWithDispatchFunction:(DispatchFunction)theFunc;

- (id)invokeWithParams:(NSArray *)theParams;

@end
