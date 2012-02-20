//
//  main.h
//  ser2avi
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef ser2avi_main_h
#define ser2avi_main_h

#import <Foundation/Foundation.h>

#pragma pack(1)
typedef struct {
    char sFileID[14];
    UInt32 uiLuID;
    UInt32 uiColorID;
    UInt32 uiLittleEndian;
    UInt32 uiImageWidth;
    UInt32 uiImageHeight;
    UInt32 uiPixelDepth;
    UInt32 uiFrameCount;
    char sObserver[40];
    char sInstrument[40];
    char sTelescope[40];
    UInt64 ulDateTime;
    UInt64 ulDateTime_UTC;                        
} SERHeader;

SERHeader readSERHeader(NSFileHandle *f);
void ser2avi();

void writeString(NSFileHandle *f, NSString *s);
void writeUInt64(NSFileHandle *f, UInt64 i);
void writeUInt32(NSFileHandle *f, UInt32 i);
void writeUInt16(NSFileHandle *f, UInt16 i);  
void writeAVIHeader(NSFileHandle *f, UInt32 frames, int width, int height, int bpp, BOOL first);
void writeFrame(NSFileHandle *f, NSData *data);

#endif
