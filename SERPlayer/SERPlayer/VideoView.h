//
//  VideoView.h
//  ViewRawVideo
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Document.h"

@interface VideoView : NSView

@property (retain, strong) NSTimer *timer;
@property (retain, strong) Document *document;
@property (assign) CGPoint zoomCenter;
@property (retain, strong) NSTrackingArea *trackingArea;

- (void)setFps:(int)fps;

@end
