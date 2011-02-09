//
//  XCMemorable.m
//  Cacao
//
//  Created by Joubert Nel on 2/4/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import "XCMemorable.h"


@implementation XCMemorable

@synthesize description = _description;
@synthesize userInfo = _userInfo;

+ (NSTreeNode *)treeNodeWithDescription:(NSString *)aDescription userInfo:(NSDictionary *)theUserInfo
{
    XCMemorable * memorable = [[XCMemorable alloc] init];
    [memorable setDescription:aDescription];
    [memorable setUserInfo:theUserInfo];
    NSTreeNode * node = [NSTreeNode treeNodeWithRepresentedObject:memorable];
    [memorable release];
    return node;    
}

@end
