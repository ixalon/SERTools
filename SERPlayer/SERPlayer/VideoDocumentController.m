//
//  VideoDocumentController.m
//  SERPlayer
//
//  Created by Chris Warren on 24/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoDocumentController.h"
#import "Document.h"
#import "DC1394.h"

@implementation VideoDocumentController

@synthesize captureLock = _captureLock;
@synthesize captureThread = _captureThread;

- (NSString*)featureToString:(dc1394feature_t)feature {
    switch(feature) {
        case DC1394_FEATURE_BRIGHTNESS: return @"Brightness";
        case DC1394_FEATURE_EXPOSURE: return @"Exposure";
        case DC1394_FEATURE_SHARPNESS: return @"Sharpness";
        case DC1394_FEATURE_WHITE_BALANCE: return @"White Balance";
        case DC1394_FEATURE_HUE: return @"Hue";
        case DC1394_FEATURE_SATURATION: return @"Saturation";
        case DC1394_FEATURE_GAMMA: return @"Gamma";
        case DC1394_FEATURE_SHUTTER: return @"Shutter";
        case DC1394_FEATURE_GAIN: return @"Gain";
        case DC1394_FEATURE_IRIS: return @"Iris";
        case DC1394_FEATURE_FOCUS: return @"Focus";
        case DC1394_FEATURE_TEMPERATURE: return @"Temperature";
        case DC1394_FEATURE_TRIGGER: return @"Trigger";
        case DC1394_FEATURE_TRIGGER_DELAY: return @"Trigger Delay";
        case DC1394_FEATURE_WHITE_SHADING: return @"White Shading";
        case DC1394_FEATURE_FRAME_RATE: return @"Frame Rate";
        case DC1394_FEATURE_ZOOM: return @"Zoom";
        case DC1394_FEATURE_PAN: return @"Pan";
        case DC1394_FEATURE_TILT: return @"Tilt";
        case DC1394_FEATURE_OPTICAL_FILTER: return @"Optical Filter";
        case DC1394_FEATURE_CAPTURE_SIZE: return @"Capture Size";
        case DC1394_FEATURE_CAPTURE_QUALITY: return @"Capture Quality";
    }
}
- (NSString*)modeToString:(dc1394feature_mode_t)mode {
    switch(mode) {
        case DC1394_FEATURE_MODE_AUTO: return @"Automatic";
        case DC1394_FEATURE_MODE_MANUAL: return @"Manual";
        case DC1394_FEATURE_MODE_ONE_PUSH_AUTO: return @"One-Push Auto";
    }
}
- (NSString*)triggerModeToString:(dc1394trigger_mode_t)mode {
    switch(mode) {
        case DC1394_TRIGGER_MODE_0: return @"Trigger Mode 0";
        case DC1394_TRIGGER_MODE_1: return @"Trigger Mode 1";
        case DC1394_TRIGGER_MODE_2: return @"Trigger Mode 2";
        case DC1394_TRIGGER_MODE_3: return @"Trigger Mode 3";
        case DC1394_TRIGGER_MODE_4: return @"Trigger Mode 4";
        case DC1394_TRIGGER_MODE_5: return @"Trigger Mode 5";
        case DC1394_TRIGGER_MODE_14: return @"Trigger Mode 14";
        case DC1394_TRIGGER_MODE_15: return @"Trigger Mode 15";
    }
}
- (NSString*)triggerSourceToString:(dc1394trigger_source_t)source {
    switch(source) {
        case DC1394_TRIGGER_SOURCE_0: return @"Trigger Source 0";
        case DC1394_TRIGGER_SOURCE_1: return @"Trigger Source 1";
        case DC1394_TRIGGER_SOURCE_2: return @"Trigger Source 2";
        case DC1394_TRIGGER_SOURCE_3: return @"Trigger Source 3";
        case DC1394_TRIGGER_SOURCE_SOFTWARE: return @"Trigger Source Software";
    }
}
- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError **)outError {    
    NSLog(@"%@", [[DC1394 sharedDC1394].cameras description]);
    
    return nil;
    
    UInt32 width = 1920, height = 1440;
    int ROI_x = 0, ROI_y = 0;
    int ROI_width = 1920, ROI_height = 1440;
    int packet_size;
    int _frameRate = 50;
    
    discardFrames = YES;
    bHasNewFrame = NO;
    
    dc1394error_t err; 
    dc1394speed_t speed;
    dc1394 = dc1394_new();
    dc1394video_mode_t video_mode = DC1394_VIDEO_MODE_FORMAT7_0;
    
    dc1394camera_list_t *cameraList;
    dc1394_camera_enumerate(dc1394, &cameraList);
    
    camera = dc1394_camera_new(dc1394, cameraList->ids[0].guid);
    
    dc1394_iso_release_bandwidth(camera, INT_MAX);
    for (int channel = 0; channel < 64; ++channel) {
        dc1394_iso_release_channel(camera, channel);
    }
    
    if (camera->bmode_capable > 0) {
        err = dc1394_video_set_operation_mode(camera, DC1394_OPERATION_MODE_1394B);
        speed = DC1394_ISO_SPEED_800;
        NSLog(@"1394B detected! Trying ISO Speed 800");
        if(err!=DC1394_SUCCESS){
            NSLog(@"Failed to set ISO Speed 800");
        }
    } else {
        speed = DC1394_ISO_SPEED_400;
    }
    
    packet_size = DC1394_USE_MAX_AVAIL;
    if(ROI_height==0) ROI_height = height;
    if(ROI_width==0)  ROI_width  = width;
    
    dc1394color_coding_t coding = DC1394_COLOR_CODING_MONO8;
    
    uint32_t bit_size;
    dc1394_get_color_coding_bit_size(coding,&bit_size);
    NSLog(@"Color coding bit-space: %i bits",bit_size);
    
    if(_frameRate!=-1) {
        float bus_period;
        if(speed == DC1394_ISO_SPEED_800) {
            bus_period = 0.0000625;
        }
        else {
            bus_period = 0.000125;
        }
        
        int num_packets = (int)(1.0/(bus_period*_frameRate)+0.5);
        packet_size = ((ROI_width - ROI_x)*(ROI_height - ROI_y)*bit_size + (num_packets*8) - 1) / (num_packets*8);
    }
    
    err = dc1394_video_set_iso_speed(camera, speed);
    if(err!=DC1394_SUCCESS){
        NSLog(@"Failed to set iso speed");
    }
    
    err = dc1394_video_set_mode(camera, video_mode);
    if(err!=DC1394_SUCCESS){
        NSLog(@"Failed to set video mode");
    }
    
    err = dc1394_format7_set_color_coding(camera, video_mode, coding);
    if(err!=DC1394_SUCCESS){
        NSLog(@"Failed to set Format 7 color coding");
    }
    
    err = dc1394_format7_set_packet_size(camera, video_mode, packet_size);
    if(err!=DC1394_SUCCESS){
        NSLog(@"Failed to set framerate / packet size");
    }
    
    err = dc1394_format7_set_roi(camera, video_mode, coding, packet_size, ROI_x,ROI_y,ROI_width,ROI_height);
    if(err!=DC1394_SUCCESS){
        NSLog(@"Failed to set ROI");
    }
    
#define PTGREY_FRAME_RATE_INQ 0x53c  
#define PTGREY_FRAME_RATE 0x83c  
#define readBits(x, pos, len) ((x >> (pos - len)) * ((1 << len) - 1))  
    
    unsigned int framerateInq;  
    dc1394_get_control_register(camera, PTGREY_FRAME_RATE_INQ, &framerateInq);  
    unsigned int minValue = readBits(framerateInq, 24, 12);  
    minValue |= 0x82000000;  
    dc1394_set_control_register(camera, PTGREY_FRAME_RATE, minValue);  
    
    if (dc1394_capture_setup(camera,4,DC1394_CAPTURE_FLAGS_DEFAULT)!=DC1394_SUCCESS)
    {
        NSLog(@"Unable to setup camera!\n\t - check that the video mode and framerate are supported by your camera.");
    }
    
    if (dc1394_video_set_transmission(camera, DC1394_ON) !=DC1394_SUCCESS)
    {
        NSLog(@"Unable to start camera iso transmission");
    }
    
    dc1394switch_t status = DC1394_OFF;        
    int counter = 0;
    while( status == DC1394_OFF && counter++ < 5 )
    {
        usleep(50000);
        if (dc1394_video_get_transmission(camera, &status)!=DC1394_SUCCESS)
        {
            NSLog(@"Unable to get transmission status.");
        }
    }
    
    if( counter == 5 )
    {
        NSLog(@"Camera doesn't seem to want to turn on!");
    }
    
    dc1394_format7_get_image_size(camera, video_mode, &width, &height);
    
    NSLog(@"Image size: %i x %i", width, height);
    
    dc1394featureset_t tmpFeatureSet;
    
    // get camera features ----------------------------------
    if ( dc1394_feature_get_all(camera, &tmpFeatureSet) !=DC1394_SUCCESS)
    {
        NSLog(@"Unable to get camera feature set.");
    }
    else
    {
        dc1394_feature_print_all(&tmpFeatureSet, stdout);
        
        for( int i = DC1394_FEATURE_MIN; i < DC1394_FEATURE_MAX; i++ )
        {
            dc1394feature_info_t* feature = &tmpFeatureSet.feature[i - DC1394_FEATURE_MIN];
            NSLog(@"-=-=-=-=-=-=-=-=-=-=-=-=-");
            NSLog(@"%@", [self featureToString:feature->id]);
            if(feature->available) {
                NSLog(@"Value: %i, Min: %i, Max: %i", feature->value, feature->min, feature->max);
                
                if(feature->absolute_capable) {
                    NSLog(@"Absolute (%f-%f): %f", feature->abs_min, feature->abs_max, feature->abs_value);
                }
                if(feature->on_off_capable) {
                    NSLog(@"Boolean: %@", feature->is_on ? @"ON" : @"OFF");                    
                }
                if(feature->abs_control) {
                    NSLog(@"Abs Control: %@", (feature->abs_control == DC1394_ON) ? @"ON" : @"OFF");
                }
                if(feature->readout_capable) {
                    NSLog(@"Readout Capable");
                }
                for(int m = DC1394_FEATURE_MODE_MIN; m < DC1394_FEATURE_MODE_MAX; m++) {
                    if(feature->modes.modes[m]) {
                        NSLog(@"%@%@", [self modeToString:m], (feature->current_mode == m) ? @" (CURRENT)":@"");
                    }
                }
                if(feature->id == DC1394_FEATURE_TRIGGER) {
                    if(feature->polarity_capable) {
                        NSLog(@"Polarity Capable");
                        NSLog(@"Current Polarity: %@", (feature->trigger_polarity == DC1394_TRIGGER_ACTIVE_LOW) ? @"LOW" : @"HIGH");
                    }

                    for(int m = DC1394_TRIGGER_MODE_MIN; m < DC1394_TRIGGER_MODE_MAX; m++) {
                        if(feature->trigger_modes.modes[m]) {
                            NSLog(@"%@%@", [self triggerModeToString:m], (feature->trigger_mode == m) ? @" (CURRENT)":@"");
                        }
                    }
                    for(int m = DC1394_TRIGGER_SOURCE_MIN; m < DC1394_TRIGGER_SOURCE_MAX; m++) {
                        if(feature->trigger_sources.sources[m]) {
                            NSLog(@"%@%@", [self triggerSourceToString:m], (feature->trigger_source == m) ? @" (CURRENT)":@"");
                        }           
                    }
                }
            } else {
                NSLog(@"Not available");
            }
            NSLog(@"-=-=-=-=-=-=-=-=-=-=-=-=-");
        }
    }
    
    dc1394_camera_free_list(cameraList);
    
    bCapture = YES;
    
    Document *doc = [super openUntitledDocumentAndDisplay:displayDocument error:outError];
    doc.footer.alphaValue = 0;
    
    SERHeader h;
    h.uiPixelDepth = bit_size;
    h.uiLittleEndian = 0;
    h.uiImageHeight = height;
    h.uiImageWidth = width;
    h.uiFrameCount = 0;
    doc.header = h;
    
    self.captureThread = [[NSThread alloc] initWithTarget:self selector:@selector(captureLoop:) object:doc];
    [self.captureThread start];
    
    return doc;
    
}

-(void) captureFrame:(Document*)doc {
    [_captureLock lock];
    if( !bHasNewFrame && (camera != NULL ))
    {
        [_captureLock unlock];
        if(discardFrames)
        {
            /*---------------------------------------------------------------------------
             *  make sure DMA buffer is fresh by dropping frames if we're lagging behind
             *--------------------------------------------------------------------------*/
            
            bool bufferEmpty = false;
            dc1394video_frame_t* frameToDiscard;
            while (!bufferEmpty){
                if (dc1394_capture_dequeue(camera, DC1394_CAPTURE_POLICY_POLL, &frameToDiscard) == DC1394_SUCCESS){
                    if(frameToDiscard != NULL){
                        dc1394_capture_enqueue(camera, frameToDiscard);
                        NSLog(@"discarded a frame");
                    } else {
                        bufferEmpty = true;
                    }
                } else {
                    bufferEmpty = true;
                }
            }
        }
        
        /*-----------------------------------------------------------------------
         *  capture one frame
         *-----------------------------------------------------------------------*/
        if (dc1394_capture_dequeue(camera, DC1394_CAPTURE_POLICY_WAIT, &frame) != DC1394_SUCCESS)
        {
            NSLog(@"unable to capture a frame\n");
        }
        else
        {
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
            
            CGContextRef bitmapContext = CGBitmapContextCreate(
                                                               (void*)frame->image,
                                                               frame->size[0],
                                                               frame->size[1],
                                                               frame->data_depth, // bitsPerComponent
                                                               frame->stride, // bytesPerRow
                                                               colorSpace,
                                                               kCGImageAlphaNone);
            
            doc.currentFrame = CGBitmapContextCreateImage(bitmapContext);
            
            dc1394_capture_enqueue(camera, frame);
        }
        
        [_captureLock lock];
        //bHasNewFrame = true;
        [_captureLock unlock];
    } else {
        [_captureLock unlock];
    }
}


-(void) captureLoop:(Document*)doc {
    
    while(bCapture) {        
        [self captureFrame:doc];
        usleep(2);
    }
}

-(void)dealloc {
    //bCapture = NO;
    
    //while(![self.captureThread isFinished]) {
        //usleep(100);
    //}
    
    //dc1394_capture_stop(camera);
    //dc1394_camera_free (camera);
    //dc1394_free(dc1394);
}

@end
