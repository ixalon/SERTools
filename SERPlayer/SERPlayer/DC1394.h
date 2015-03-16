//
//  DC1394.h
//  SERPlayer
//
//  Created by Chris Warren on 24/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "camera.h"

@interface DC1394 : NSObject

@property (readonly, nonatomic) dc1394_t* dc1394;
@property (readonly, nonatomic, strong) NSArray* cameras;

+ (DC1394*)sharedDC1394;

@end
