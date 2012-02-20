//
//  AppDelegate.m
//  ViewRawVideo
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize video = _video;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.video = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    self.window.contentView = _video.view;
    [self.window makeKeyAndOrderFront:_video.view];
}

@end
