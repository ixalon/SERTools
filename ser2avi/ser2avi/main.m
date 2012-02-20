//
//  main.m
//  ser2avi
//
//  Created by Chris Warren on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "main.h"

#define AVIF_HASINDEX           0x00000010      /* Index at end of file */
#define AVIF_MUSTUSEINDEX       0x00000020
#define AVIF_ISINTERLEAVED      0x00000100
#define AVIF_TRUSTCKTYPE        0x00000800      /* Use CKType to find key frames */
#define AVIF_WASCAPTUREFILE     0x00010000
#define AVIF_COPYRIGHTED        0x00020000

/*
void raw2ser() {
    NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath: @"/Users/chris/capture_video_20120219132114.raw"];
    [[NSFileManager defaultManager] createFileAtPath:@"/Users/chris/capture_video_20120219132114.ser" contents:nil attributes:nil];
    NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath: @"/Users/chris/capture_video_20120219132114.ser"];
    
    int width = 1920;
    int height = 1440;
    int bpp = 1;
    int frameSize = width * height * bpp;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    unsigned long long fileSize = [[fm attributesOfItemAtPath:@"/Users/chris/capture_video_20120219132114.raw" error:NULL] fileSize];
    
    unsigned long long totalFrames = (fileSize / frameSize);
    //[input seekToFileOffset:frameSize * 700];
    
    writeString(output, @"LUCAM-RECORDER");
    writeUInt32(output, 0); // LuID (0 = unknown)
    writeUInt32(output, 0); // ColorID (0 = MONO)
    writeUInt32(output, 0); // LittleEndian (0 = Big endian)
    writeUInt32(output, width); // ImageWidth
    writeUInt32(output, height); // ImageHeight
    writeUInt32(output, 8); // PixelDepth
    writeUInt32(output, (UInt32)totalFrames); // FrameCount
    //1234567890123456789012345678901234567890
    writeString(output, @"Chris Warren                            ");
    writeString(output, @"Point Grey Grasshopper Express ICX674   ");
    writeString(output, @"Lunt LS60THa                            ");
    writeUInt64(output, 0);
    writeUInt64(output, 0);
    
    NSData *data = nil;
    int frame = 0;
    do {
        data = [input readDataOfLength:frameSize];
        if([data length] == frameSize) {
            [output writeData:data];
            frame++;                
        }
    } while ([data length] > 0);
    
    [input closeFile];
    [output closeFile];
}
*/

int main (int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        ser2avi();
        
    }
    return 0;
}

SERHeader readSERHeader(NSFileHandle *f) {
    SERHeader header;
    
    NSData *data = [f readDataOfLength:sizeof(header)];
    [data getBytes:&header length:sizeof(header)];
    
    return header;
}
void ser2avi() {
    NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath: @"/Users/chris/capture_video_20120219132114.ser"];
    [[NSFileManager defaultManager] createFileAtPath:@"/Users/chris/capture_video_20120219132114.avi" contents:nil attributes:nil];
    NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath: @"/Users/chris/capture_video_20120219132114.avi"];
    
    SERHeader header = readSERHeader(input);
    
    int frameSize = header.uiImageWidth * header.uiImageHeight * header.uiPixelDepth / 8;
    
    unsigned long long framesPerRIFF = floor(((1024 * 1024 * 1024) - 1024) / frameSize);
    
    NSData *data = nil;
    unsigned int frame = 0;
    do {
        data = [input readDataOfLength:frameSize];
        if([data length] == frameSize) {
            if(frame % framesPerRIFF == 0) {
                unsigned long long frames = MIN(framesPerRIFF, header.uiFrameCount - frame);
                NSLog(@"Writing header at frame: %u/%u for %llu frames.", frame, header.uiFrameCount, frames);
                writeAVIHeader(output, (UInt32)frames, header.uiImageWidth, header.uiImageHeight, header.uiPixelDepth / 8, frame == 0);
            }
            writeFrame(output, data);
            frame++;                
        }
    } while ([data length] > 0);
    
    [input closeFile];
    [output closeFile];
}

void writeString(NSFileHandle *f, NSString *s) {  
    [f writeData:[s dataUsingEncoding:NSASCIIStringEncoding]];
}
void writeUInt64(NSFileHandle *f, UInt64 i) {  
    [f writeData:[NSData dataWithBytes:&i length:8]];
}
void writeUInt32(NSFileHandle *f, UInt32 i) {  
    [f writeData:[NSData dataWithBytes:&i length:4]];
}
void writeUInt16(NSFileHandle *f, UInt16 i) {  
    [f writeData:[NSData dataWithBytes:&i length:2]];
}
void writeAVIHeader(NSFileHandle *f, UInt32 frames, int width, int height, int bpp, BOOL first) {
    int frameSize = width * height * bpp;
    int dataPerFrame = frameSize + 8;
    
    NSLog(@"Writing RIFF chunk at %llu", [f offsetInFile]);
    writeString(f, @"RIFF");
    
    if(first) {
        writeUInt32(f, 32 + 16 + 176 + (dataPerFrame * frames));
        NSLog(@"Length: %u - Next RIFF at: %llu", 32 + 16 + 176 + (dataPerFrame * frames), [f offsetInFile] + 32 + 16 + 176 + (dataPerFrame * frames));
        writeString(f, @"AVI ");
        
        writeString(f, @"LIST");
        writeUInt32(f, 176);    
        writeString(f, @"hdrl");
        
        writeString(f, @"avih");
        writeUInt32(f, 14 * 4);
        
        // typedef struct {} MainAVIHeader
        writeUInt32(f, 0); // DWORD dwMicroSecPerFrame; // frame display rate (or 0)
        writeUInt32(f, 0); // DWORD dwMaxBytesPerSec; // max. transfer rate
        writeUInt32(f, 0); // DWORD dwPaddingGranularity; // pad to multiples of this
        writeUInt32(f, 0); // DWORD dwFlags; // the ever-present flags
        writeUInt32(f, frames); // DWORD dwTotalFrames; // # frames in file
        writeUInt32(f, 0); // DWORD dwInitialFrames;
        writeUInt32(f, 1); // DWORD dwStreams;
        writeUInt32(f, frameSize); // DWORD dwSuggestedBufferSize;
        writeUInt32(f, width); // DWORD dwWidth;
        writeUInt32(f, height); // DWORD dwHeight;
        
        /* MS calls the following 'reserved': */
        writeUInt32(f, 0);                  /* TimeScale:  Unit used to measure time */
        writeUInt32(f, 0);                  /* DataRate:   Data rate of playback     */
        writeUInt32(f, 0);                  /* StartTime:  Starting time of AVI data */
        writeUInt32(f, 0);                  /* DataLength: Size of AVI data chunk    */
        
        writeString(f, @"LIST");
        writeUInt32(f, 116);            
        writeString(f, @"strl");
        
        writeString(f, @"strh");
        writeUInt32(f, 64);    
        
        // typedef struct { } AVIStreamHeader;
        writeString(f, @"vids"); // FOURCC  fccType;
        writeString(f, @"Y800"); // FOURCC  fccHandler;
        writeUInt32(f, 0); // DWORD   dwFlags;   
        writeUInt16(f, 0); // WORD    wPriority;  
        writeUInt16(f, 0); // WORD    wLanguage;   
        writeUInt32(f, 0); // DWORD   dwInitialFrames;   
        writeUInt32(f, 1000); // DWORD   dwScale;   
        writeUInt32(f, 25 * 1000); // DWORD   dwRate;   
        writeUInt32(f, 0); // DWORD   dwStart;   
        writeUInt32(f, frames); // DWORD   dwLength;   
        writeUInt32(f, frameSize); // DWORD   dwSuggestedBufferSize;    
        writeUInt32(f, -1); // DWORD   dwQuality;   
        writeUInt32(f, 0); // DWORD   dwSampleSize;   
        
        writeUInt32(f, 0); // RECT    rcFrame (left);   
        writeUInt32(f, 0); // RECT    rcFrame (top);    
        writeUInt32(f, width); // RECT    rcFrame (width);   
        writeUInt32(f, height); // RECT    rcFrame (height); 
        
        writeString(f, @"strf");
        writeUInt32(f, 40);
        
        // typedef struct {} BITMAPINFOHEADER;
        writeUInt32(f, 40); // DWORD biSize;
        writeUInt32(f, width); // LONG  biWidth;
        writeUInt32(f, height); // LONG  biHeight;
        writeUInt16(f, 1); // WORD  biPlanes;
        writeUInt16(f, 8); // WORD  biBitCount;
        writeUInt32(f, 0); // DWORD biCompression;
        writeUInt32(f, 0); // DWORD biSizeImage;
        writeUInt32(f, 0); // LONG  biXPelsPerMeter;
        writeUInt32(f, 0); // LONG  biYPelsPerMeter;
        writeUInt32(f, 0); // DWORD biClrUsed;
        writeUInt32(f, 0); // DWORD biClrImportant;
    } else {
        writeUInt32(f, 16 + (dataPerFrame * frames)); 
        NSLog(@"Length: %i - Next RIFF at: %llu", 8 + (dataPerFrame * frames), [f offsetInFile] + 16 + (dataPerFrame * frames));
        
        writeString(f, @"AVIX");        
    }
    
    writeString(f, @"LIST");
    
    writeUInt32(f, 4 + (dataPerFrame * frames));    
    
    writeString(f, @"movi");
}
void writeFrame(NSFileHandle *f, NSData *data) {    
    writeString(f, @"00dc");
    writeUInt32(f, (UInt32)[data length]);
    [f writeData:data];
}