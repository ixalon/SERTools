//
//  DC1394Feature.h
//  SERPlayer
//
//  Created by Chris Warren on 25/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "camera.h"

@interface DC1394Feature : NSObject

@property (readonly) dc1394feature_info_t feature;

-(id)initWithFeatureInfo:(dc1394feature_info_t)feature;
+(DC1394Feature*)featureWithFeatureInfo:(dc1394feature_info_t)feature;

@end
