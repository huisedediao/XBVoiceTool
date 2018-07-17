//
//  Header_audio.h
//  XBVoiceTool
//
//  Created by xxb on 2018/6/27.
//  Copyright © 2018年 xxb. All rights reserved.
//

#ifndef Header_audio_h
#define Header_audio_h

#define kInputBus (1)
#define kOutputBus (0)

#define NO_MORE_DATA (-12306)

#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "Header_audio.h"
#import <assert.h>

#define kPreferredIOBufferDuration (0.05)

#define CONST_BUFFER_SIZE (0x10000)

typedef enum : NSUInteger {
    XBVoiceRate_8k = 8000,
    XBVoiceRate_20k = 20000,
    XBVoiceRate_44k = 44100,
    XBVoiceRate_96k = 96000
} XBVoiceRate;

typedef enum : NSUInteger {
    XBVoiceBit_8 = 8,
    XBVoiceBit_16 = 16,
} XBVoiceBit;

typedef enum : NSUInteger {
    XBVoiceChannel_1 = 1,
    XBVoiceChannel_2 = 2,
} XBVoiceChannel;

typedef enum : NSUInteger {
    XBEchoCancellationStatus_open,
    XBEchoCancellationStatus_close
} XBEchoCancellationStatus;

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

#endif /* Header_audio_h */
