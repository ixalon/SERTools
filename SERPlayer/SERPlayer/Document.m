//
//  Document.m
//  SERPlayer2
//
//  Created by Chris Warren on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Document.h"
#import "VideoView.h"

@implementation Document

@synthesize video = _video;
@synthesize file = _file;
@synthesize currentFrame = _currentFrame;
@synthesize slider = _slider;
@synthesize jogControl = _jogControl;
@synthesize frame = _frame;
@synthesize length = _length;
@synthesize fps = _fps;
@synthesize footer = _footer;
@synthesize header = _header;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    //self.windowForSheet.contentView = _video.view;
    //[self.windowForSheet makeKeyAndOrderFront:_video.view];
    
    self.video.document = self;
    
    _frame.stringValue = @"0";
    [_slider setMaxValue:self.header.uiFrameCount];
    _length.stringValue = [NSString stringWithFormat:@"%u", (UInt32)_slider.maxValue];
    [_slider setIntValue:0]; 
    [_slider setNumberOfTickMarks:self.header.uiFrameCount/20];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)isEntireFileLoaded {
    return NO;
}
- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {    
    self.file = [NSFileHandle fileHandleForReadingAtPath:[self fileName]];

    return [self readSERHeader];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}


- (BOOL)readSERHeader {
    SERHeader header;
    
    @try {
        [self.file seekToFileOffset:0];
        NSData *data = [self.file readDataOfLength:sizeof(header)];
        [data getBytes:&header length:sizeof(header)];
        self.header = header;
        currentFrameNumber = 0;
        return self.header.uiFrameCount > 0;
    }
    @catch (NSException *exception) {
        return NO;
    }
}
- (void)seekToFrame:(UInt32)frame {
    frame = frame - 1;
    unsigned long long frameSize = self.header.uiImageWidth * self.header.uiImageHeight * self.header.uiPixelDepth / 8;
    [self.file seekToFileOffset: sizeof(self.header) + (frameSize * frame)];
    currentFrameNumber = frame;
    
    [self updateUI];
}

- (void)updateUI {
    [_frame setIntValue:currentFrameNumber];
}

- (void)centerImage:(unsigned char*)img x:(int)x y:(int)y width:(int)width height:(int)height {
    if(translated == NULL) {
        translated = malloc(width * height);
    }
    
    memset(translated, 0, width * height);
    
    unsigned char *dst = translated;
    
    int top = y - (height / 2);
    int left = x - (width / 2);
    int copyWidth = left < 0 ? width + left : width;
    
    unsigned char *srcEnd = img + (width * height) - copyWidth;
    unsigned char *dstEnd = dst + (width * height) - copyWidth;

    if(top < 0) {
        dst -= (width * top);
    } else {
        img -= (width * top);
    }
    
    if(left < 0) {
        img += left;
    } else {
        dst += left;
    }
        
    do {
        memcpy(dst, img, copyWidth);
        img += width;
        dst += width;
    } while(dst < dstEnd && img < srcEnd);
}

- (void)addFrame:(unsigned char*)img width:(int)width height:(int)height {
    if(sum == NULL) {
        sum = malloc(sizeof(unsigned long) * width * height);
    }

    unsigned long *dst = sum; 
    unsigned char *end = img + (width * height);
    do {
        *dst += *img;
        dst++;
    } while(++img < end);
    count++;
}

- (void)getAverageFrame:(int)width height:(int)height {
    unsigned char *dst = translated; 
    unsigned long *src = sum;
    unsigned char *end = dst + (width * height);
    do {
        *dst = *src / count;
        src++;
    } while(++dst < end);
}

- (void)getNextFrame {
    if(!self.file) {
        return;
    }
    
    int width = self.header.uiImageWidth;
    int height = self.header.uiImageHeight;
    int bpp = self.header.uiPixelDepth;
    
    int frameSize = width * height * bpp / 8;
    __block unsigned long avgX = 0;
    __block unsigned long avgY = 0;
    __block unsigned long avgCount = 0;
    
    NSData *data = [self.file readDataOfLength:frameSize];
        
    if([data length] == frameSize) {
        if(self.currentFrame) {
            CFRelease(self.currentFrame);
            self.currentFrame = nil;
        }
        
        unsigned char *ptr = (unsigned char*)data.bytes;
        dispatch_apply(4, dispatch_get_global_queue(0, 0), ^(size_t i){
            unsigned int fromRow = (height * i) / 4.0;
            unsigned int toRow = fromRow + (height / 4.0);
                        
            unsigned char *from = ptr+(fromRow*width);
            unsigned char *to = ptr+(toRow*width);

            unsigned int x = 0;
            unsigned int y = fromRow;
            unsigned long xc = 0;
            unsigned long yc = 0;
            unsigned long c = 0;
            do {
                if(*from > 16) {
                    xc += x;
                    yc += y;
                    c++;
                }
                if(++x == width) {
                    x = 0;
                    y++;
                }
            } while(++from < to);  
            
            avgX += xc;
            avgY += yc;
            avgCount += c;
        });
        
        if(avgCount != 0) {
            center.x = avgX / avgCount;
            center.y = avgY / avgCount;
        }
        
        //[self centerImage:(unsigned char*)data.bytes x:center.x y:center.y width:width height:height];
        //[self addFrame:translated width:width height:height];
        //[self getAverageFrame:width height:height];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        CGContextRef bitmapContext = CGBitmapContextCreate(
                                                           (void*)data.bytes,
                                                           width,
                                                           height,
                                                           bpp, // bitsPerComponent
                                                           (bpp*width)/8, // bytesPerRow
                                                           colorSpace,
                                                           kCGImageAlphaNone);
        
        self.currentFrame = CGBitmapContextCreateImage(bitmapContext);
        
        CFRelease(colorSpace);
        
        currentFrameNumber++;
        [_slider setIntValue:currentFrameNumber];
        [self updateUI];
    }
    
}

- (NSPoint)getCenter {
    return center;
}

- (IBAction)sliderDone:(id)sender {
}
- (IBAction)sliderChanged:(id)sender {
    SEL sel = @selector( sliderDone: );
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:sel object:sender];
    [self performSelector:sel withObject:sender afterDelay:0.0];
    [self seekToFrame:[_slider intValue]];
    [self getNextFrame];
    [self.video setNeedsDisplay:YES];
}
- (IBAction)jogControlChanged:(id)sender {
    [self.video setFps:[self.jogControl intValue]];
    [self.fps setStringValue:[NSString stringWithFormat:@"%u fps", [self.jogControl intValue]]];
}

@end
