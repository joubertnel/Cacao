//
//  CCUtil.h
//  Cacao
//
//  Created by Joubert Nel on 11/12/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCUtil : NSObject {

}

+ (bool)is:(NSObject *)o1 equivalentTo:(NSObject *)o2;
+ (bool)isPersistentCollection:(id <CCPersistentCollection>)o1 equivalentTo:(id <CCPersistentCollection>)o2;
@end
