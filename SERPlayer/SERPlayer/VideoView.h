//
//  VideoView.h
//  ViewRawVideo
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SER.h"

@interface VideoView : NSView

@property (retain, strong) NSFileHandle *file;
@property (assign) CGImageRef currentFrame;
@property (retain, strong) NSTimer *timer;
@property (assign) SERHeader header;
- (BOOL)loadVideo:(NSString*)f;
- (BOOL)readSERHeader;
- (void)getNextFrame;

@end
