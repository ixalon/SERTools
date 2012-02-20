//
//  VideoView.h
//  ViewRawVideo
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VideoView : NSView

@property (retain, strong) NSFileHandle *file;
@property (assign) CGImageRef currentFrame;
@property (retain, strong) NSTimer *timer;

- (void)getNextFrame;

@end
