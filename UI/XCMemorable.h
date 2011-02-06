//
//  XCMemorable.h
//  Cacao
//
//  Created by Joubert Nel on 2/4/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XCMemorable : NSObject {
    NSString * _displayName;
    NSArray * _children;
}

@property (assign) NSString * displayName;
@property (nonatomic, retain) NSArray * children;

@end
