//
//  XocoAppDelegate.h
//  Cacao
//
//  Created by Joubert Nel on 2/3/11.
//  Copyright 2011 Joubert Nel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * XCEvalNotificationName;

@interface XocoAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow * window;    
    IBOutlet NSTextView * inputView;
    IBOutlet NSTextView * outputView;
    
    NSTreeController * cacaoMemoryTreeController;
}

@property (assign) IBOutlet NSWindow * window;
@property (nonatomic, retain) IBOutlet NSTreeController * cacaoMemoryTreeController;





@end
