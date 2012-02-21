//
//  Document.h
//  SERPlayer2
//
//  Created by Chris Warren on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VideoViewController.h"

@interface Document : NSDocument

@property (retain, strong) VideoViewController *video;

@end
