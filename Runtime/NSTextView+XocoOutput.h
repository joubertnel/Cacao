//
//  NSMutableAttributedString+Xoco.h
//  Cacao
//
//  Created by Joubert Nel on 2/4/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSTextView (XocoOutput)

- (void)appendRegularString:(NSString *)theString;
- (void)scrollToLastVisible;

@end
