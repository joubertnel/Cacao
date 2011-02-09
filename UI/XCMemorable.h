//
//  XCMemorable.h
//  Cacao
//
//  Created by Joubert Nel on 2/4/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString * XCMemorable

@interface XCMemorable : NSObject {
    NSString * _description;
    NSDictionary * _userInfo;
}

@property (copy) NSString * description;
@property (nonatomic, retain) NSDictionary * userInfo;

+ (NSTreeNode *)treeNodeWithDescription:(NSString *)aDescription userInfo:(NSDictionary *)theUserInfo;

@end
