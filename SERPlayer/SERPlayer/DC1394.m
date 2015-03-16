//
//  DC1394.m
//  SERPlayer
//
//  Created by Chris Warren on 24/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DC1394.h"
#import "DC1394Camera.h"

static DC1394 *sharedDC1394 = nil;

@implementation DC1394

@synthesize dc1394 = _dc1394;
@synthesize cameras = _cameras;

+ (DC1394*)sharedDC1394 {
    @synchronized(self) {
        if (sharedDC1394 == nil) {
            sharedDC1394 = [[self alloc] init];
        }
    }
    return sharedDC1394;
}

-(id) init {
    if(self = [super init]) {
        _dc1394 = dc1394_new();
        
        dc1394camera_list_t *cameraList;
        dc1394_camera_enumerate(_dc1394, &cameraList);
        
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:cameraList->num];
        for(int i = 0; i < cameraList->num; i++) {
            [tmp addObject:[DC1394Camera cameraWithID:cameraList->ids[i]]];
        }
        _cameras = [NSArray arrayWithArray:tmp];
        
        dc1394_camera_free_list(cameraList);
    }
    return self;
}
- (void)dealloc {
    dc1394_free(_dc1394);
}

@end
