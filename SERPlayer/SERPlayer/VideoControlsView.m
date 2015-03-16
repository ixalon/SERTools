//
//  VideoControlsView.m
//  SERPlayer
//
//  Created by Chris Warren on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoControlsView.h"

@implementation VideoControlsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.3,0.3,0.3,0.5);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.5);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:5 yRadius:5];
    [path fill];
    [path stroke];
}

@end
