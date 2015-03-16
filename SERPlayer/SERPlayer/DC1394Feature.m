//
//  DC1394Feature.m
//  SERPlayer
//
//  Created by Chris Warren on 25/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DC1394Feature.h"

@implementation DC1394Feature

@synthesize feature = _feature;

-(id)initWithFeatureInfo:(dc1394feature_info_t)feature {
    self = [super init];
    if(self) {
        _feature = feature;
    }
    return self;
}
+(DC1394Feature*)featureWithFeatureInfo:(dc1394feature_info_t)feature {
    return [[DC1394Feature alloc] initWithFeatureInfo:feature];
}

@end
