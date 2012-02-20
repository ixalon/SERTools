//
//  VideoView.m
//  ViewRawVideo
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView

@synthesize file = _file;
@synthesize currentFrame = _currentFrame;
@synthesize timer = _timer;
@synthesize header = _header;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.file = [NSFileHandle fileHandleForReadingAtPath: @"/Users/chris/capture_video_20120219132114.ser"];
        self.header = [self readSERHeader:self.file];
        self.currentFrame = nil;
        self.timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(incrementFrame:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)dealloc {
    [self.file closeFile];
    if(self.currentFrame) {
        CFRelease(self.currentFrame);
        self.currentFrame = nil;
    }
}

- (void)incrementFrame:(NSTimer*)timer {
    [self getNextFrame];
    [self setNeedsDisplay:YES];
}

- (SERHeader)readSERHeader:(NSFileHandle*)f {
    SERHeader header;
    
    NSData *data = [f readDataOfLength:sizeof(header)];
    [data getBytes:&header length:sizeof(header)];
    
    return header;
}

- (void)getNextFrame {
    if(self.currentFrame) {
        CFRelease(self.currentFrame);
        self.currentFrame = nil;
    }
    
    int width = self.header.uiImageWidth;
    int height = self.header.uiImageHeight;
    int bpp = self.header.uiPixelDepth;
    int frameSize = width * height * bpp / 8;
    
    NSData *data = [self.file readDataOfLength:frameSize];
        
    if([data length] == frameSize) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        CGContextRef bitmapContext = CGBitmapContextCreate(
                                                           (void*)[data bytes],
                                                           width,
                                                           height,
                                                           bpp, // bitsPerComponent
                                                           (bpp*width)/8, // bytesPerRow
                                                           colorSpace,
                                                           kCGImageAlphaNone);
        
        self.currentFrame = CGBitmapContextCreateImage(bitmapContext);

        CFRelease(colorSpace);
    } else {
        [self.file seekToFileOffset:0];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(self.currentFrame) {
        float fScale = (float)self.visibleRect.size.height / self.header.uiImageHeight;
        float fWidth = self.header.uiImageWidth * fScale;
        float fHeight = self.visibleRect.size.height;
        float fLeft = ((float)self.visibleRect.size.width - fWidth) / 2.0;
        float fTop = 0;
        
        
        CGRect imageRect = CGRectMake(
                                      fLeft,
                                      fTop,
                                      fWidth,
                                      fHeight);
        
        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]     graphicsPort];
        
        [[NSColor blackColor] setFill];
        CGContextFillRect(context, self.visibleRect);
        CGContextDrawImage(context, imageRect, self.currentFrame);
    }
}

@end
