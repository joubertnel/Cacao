//
//  CacaoReadable.h
//  Cacao
//
//  Created by Joubert Nel on 1/11/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol CacaoReadable

- (NSString *)readableValue;
- (void)writeToFile:(NSString *)path;

@end
