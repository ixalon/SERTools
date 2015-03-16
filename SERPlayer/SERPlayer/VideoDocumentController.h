//
//  VideoDocumentController.h
//  SERPlayer
//
//  Created by Chris Warren on 24/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "camera.h"

@interface VideoDocumentController : NSDocumentController {
    dc1394_t *dc1394;
    dc1394camera_t *camera;
    dc1394video_frame_t* frame;
    bool discardFrames;
    bool bHasNewFrame;
    bool bCapture;
}

@property (assign) NSLock *captureLock;
@property (retain, strong) NSThread *captureThread;

@end
