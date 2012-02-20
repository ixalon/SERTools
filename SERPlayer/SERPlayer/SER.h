//
//  SER.h
//  SERPlayer
//
//  Created by Chris Warren on 20/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef SERPlayer_SER_h
#define SERPlayer_SER_h

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

#endif
