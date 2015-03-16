//
//  DC1394Camera.m
//  SERPlayer
//
//  Created by Chris Warren on 24/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DC1394.h"
#import "DC1394Camera.h"
#import "DC1394Feature.h"
#import "camera.h"

@implementation DC1394Camera

@synthesize cameraID = _cameraID;

-(id)initWithCameraID:(dc1394camera_id_t)cameraID {
    self = [super init];
    if(self) {
        _cameraID = cameraID;
    }
    return self;
}
-(id)initWithCamera:(dc1394camera_t*)camera {
    self = [super init];
    if(self) {
        _camera = camera;
    }
    return self;
}
+(DC1394Camera*)cameraWithID:(dc1394camera_id_t)cameraID {
    return [[DC1394Camera alloc] initWithCameraID:cameraID];
}
+(DC1394Camera*)cameraWithCamera:(dc1394camera_t*)camera {
    return [[DC1394Camera alloc] initWithCamera:camera];
}

-(NSArray*)features {
    NSMutableArray *features = [NSMutableArray arrayWithCapacity:DC1394_FEATURE_NUM];
    
    dc1394featureset_t tmpFeatureSet;
    if ( dc1394_feature_get_all(self.camera, &tmpFeatureSet) == DC1394_SUCCESS)
    {
        dc1394_feature_print_all(&tmpFeatureSet, stdout);
        for( int i = DC1394_FEATURE_MIN; i < DC1394_FEATURE_MAX; i++ ) {
            [features addObject:[DC1394Feature featureWithFeatureInfo:tmpFeatureSet.feature[i]]];
        }
    }
    
    return [NSArray arrayWithArray:features];
}

-(dc1394camera_t*)camera {
    if(!_camera) {
        _camera = dc1394_camera_new_unit([[DC1394 sharedDC1394] dc1394], _cameraID.guid, _cameraID.unit);
    }
    return _camera;
}

-(void)dealloc {
    if(_camera) {
        dc1394_camera_free(_camera);
    }
}

@end
