//
//  CacaoQuotedForm.h
//  Cacao
//
//  Created by Joubert Nel on 1/4/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CacaoQuotedForm : NSObject {
    id form;
}

@property (nonatomic, retain) id form;


- (NSString *)printable;

@end
