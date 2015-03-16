//
//  DC1394Camera.h
//  SERPlayer
//
//  Created by Chris Warren on 24/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "camera.h"

@interface DC1394Camera : NSObject {
    dc1394camera_t* _camera;
}

@property (readonly) dc1394camera_id_t cameraID;
@property (readonly, nonatomic, assign) dc1394camera_t* camera;

@property (readonly, nonatomic, strong) NSArray* features;

-(id)initWithCameraID:(dc1394camera_id_t)cameraID;
-(id)initWithCamera:(dc1394camera_t*)camera;

+(DC1394Camera*)cameraWithID:(dc1394camera_id_t)cameraID;
+(DC1394Camera*)cameraWithCamera:(dc1394camera_t*)camera;

@end
