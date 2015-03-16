//
//  Document.h
//  SERPlayer2
//
//  Created by Chris Warren on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SER.h"

@class VideoView;

@interface Document : NSDocument {
    UInt32 currentFrameNumber;
    NSPoint center;
    unsigned char *translated;
    unsigned long *sum;
    unsigned long count;
}

@property (nonatomic, assign) CGImageRef currentFrame;
@property (nonatomic, retain, strong) NSFileHandle *file;
@property (nonatomic, assign) SERHeader header;

@property (nonatomic, retain) IBOutlet VideoView *video;
@property (nonatomic, retain) IBOutlet NSSlider *slider;
@property (nonatomic, retain) IBOutlet NSSlider *jogControl;
@property (nonatomic, retain) IBOutlet NSTextField *frame;
@property (nonatomic, retain) IBOutlet NSTextField *length;
@property (nonatomic, retain) IBOutlet NSTextField *fps;
@property (nonatomic, retain) IBOutlet NSView *footer;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)jogControlChanged:(id)sender;
- (BOOL)loadVideo:(NSString*)f;
- (BOOL)readSERHeader;
- (void)getNextFrame;
- (void)seekToFrame:(UInt32)frame;
- (void)updateUI;
- (NSPoint)getCenter;
- (void)centerImage:(unsigned char*)img x:(int)x y:(int)y width:(int)width height:(int)height;

@end
