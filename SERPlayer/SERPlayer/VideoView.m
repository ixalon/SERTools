//
//  VideoView.m
//  ViewRawVideo
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView

@synthesize document = _document;
@synthesize timer = _timer;
@synthesize zoomCenter = _zoomCenter;
@synthesize trackingArea = _trackingArea;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.timer = [NSTimer timerWithTimeInterval:1.0/25.0 target:self selector:@selector(incrementFrame:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    
    return self;   
}

- (void)incrementFrame:(NSTimer*)timer {
    //[self.document performSelectorOnMainThread:@selector(getNextFrame) withObject:nil waitUntilDone:YES];
    [self.document getNextFrame];
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
    if(self.document.currentFrame) {
        float fScale = (float)self.visibleRect.size.height / self.document.header.uiImageHeight;
        float fWidth = self.document.header.uiImageWidth * fScale;
        float fHeight = self.visibleRect.size.height;
        float fLeft = ((float)self.visibleRect.size.width - fWidth) / 2.0;
        float fTop = 0;
        
        //NSPoint center = [self.document getCenter];
        //fLeft = (self.visibleRect.size.width / 2.0) - (center.x * fScale);
        //fTop = (self.visibleRect.size.height / 2.0) - (self.visibleRect.size.height - (center.y * fScale));
        
        float fZoomSize = 200;
        
        CGRect imageRect = CGRectMake(
                                      fLeft,
                                      fTop,
                                      fWidth,
                                      fHeight);
        
        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]     graphicsPort];
        
        [[NSColor blackColor] setFill];
        CGContextFillRect(context, self.visibleRect);
        CGContextDrawImage(context, imageRect, self.document.currentFrame);
        
        CGRect rectOfPicToLoad = CGRectMake(((self.zoomCenter.x - fLeft)/fScale)-(fZoomSize/2), ((self.zoomCenter.y - fTop)/fScale)-(fZoomSize/2), fZoomSize, fZoomSize);
        CGImageRef _imageRef = CGImageCreateWithImageInRect(self.document.currentFrame, rectOfPicToLoad);
        CGContextDrawImage(context, CGRectMake(self.zoomCenter.x - (fZoomSize/2), self.visibleRect.size.height - self.zoomCenter.y - (fZoomSize/2), fZoomSize, fZoomSize), _imageRef);
        CGImageRelease(_imageRef);
        
        [[NSColor redColor] setStroke];
        
        /*
        CGContextMoveToPoint(context, fLeft + (center.x * fScale), 0);
        CGContextAddLineToPoint(context, fLeft + (center.x * fScale), self.visibleRect.size.height);
        CGContextStrokePath(context);
  
        CGContextMoveToPoint(context, 0, self.visibleRect.size.height - (center.y * fScale));
        CGContextAddLineToPoint(context, self.visibleRect.size.width, self.visibleRect.size.height - (center.y * fScale));
        CGContextStrokePath(context);
*/
        
    }
}

- (void)setFps:(int)fps {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:1.0/fps target:self selector:@selector(incrementFrame:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void) viewWillMoveToWindow:(NSWindow *)newWindow {
    // Setup a new tracking area when the view is added to the window.
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingMouseMoved) owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}
- (void)updateTrackingAreas
{
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingMouseMoved) owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}
- (void)mouseMoved:(NSEvent *)theEvent {
    self.zoomCenter = CGPointMake(theEvent.locationInWindow.x, self.visibleRect.size.height - theEvent.locationInWindow.y);
}

@end
