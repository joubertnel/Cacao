//
//  CacaoSymbol.h
//  Cacao
//
//  Created by Joubert Nel on 11/13/10.
//  Copyright 2010 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CacaoSymbol : NSObject <NSCopying> {
    NSString * name;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ns;

+ (CacaoSymbol *)symbolWithName:(NSString *)theName;

- (BOOL)isEqualToSymbol:(CacaoSymbol *)otherSymbol;

- (NSString *)stringValue;
- (NSString *)printable;
- (id)copyWithZone:(NSZone *)zone;


@end
