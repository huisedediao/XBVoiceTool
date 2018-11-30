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


#define kSmapleRate (XBAudioRate_44k * 1.0)
#define kFramesPerPacket (1)
#define kChannelsPerFrame (2)
#define kBitsPerChannel (32)  //s16


#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "Header_audio.h"
#import <assert.h>

#define kPreferredIOBufferDuration (0.05)

#define CONST_BUFFER_SIZE (0x10000)

typedef enum : NSUInteger {
    XBAudioRate_8k = 8000,
    XBAudioRate_16k = 16000,
    XBAudioRate_20k = 20000,
    XBAudioRate_44k = 44100,
    XBAudioRate_96k = 96000
} XBAudioRate;

typedef enum : NSUInteger {
    XBAudioBit_8 = 8,
    XBAudioBit_16 = 16,
    XBAudioBit_32 = 32,
} XBAudioBit;

typedef enum : NSUInteger {
    XBAudioChannel_1 = 1,
    XBAudioChannel_2 = 2,
} XBAudioChannel;

typedef enum : NSUInteger {
    XBEchoCancellationStatus_open,
    XBEchoCancellationStatus_close
} XBEchoCancellationStatus;

struct XBAudioBuffer {
    AudioStreamBasicDescription asbd;
    Float32 *leftData;//左声道数据
    Float32 *rightData;//右声道数据
    UInt64 totalFrames;//总帧数
    UInt64 startFrame;//从第几帧开始读
    UInt32 channelCount; //声音是单声道还是立体声
};
typedef struct XBAudioBuffer XBAudioBuffer;


typedef enum : NSUInteger {
    XBAudioFormatFlags_Float = kAudioFormatFlagIsFloat,
    XBAudioFormatFlags_BigEndian = kAudioFormatFlagIsBigEndian,
    XBAudioFormatFlags_SignedInteger = kAudioFormatFlagIsSignedInteger,
    XBAudioFormatFlags_Packed = kAudioFormatFlagIsPacked,
    XBAudioFormatFlags_AlignedHigh = kAudioFormatFlagIsAlignedHigh,
    XBAudioFormatFlags_NonInterleaved = kAudioFormatFlagIsNonInterleaved,
    XBAudioFormatFlags_NonMixable = kAudioFormatFlagIsNonMixable,
    XBAudioFormatFlags_AreAllClear = kAudioFormatFlagsAreAllClear,
} XBAudioFormatFlags;
/*
 CF_ENUM(AudioFormatFlags)
 {
 kAudioFormatFlagIsFloat                     = (1U << 0),     // 0x1
 kAudioFormatFlagIsBigEndian                 = (1U << 1),     // 0x2
 kAudioFormatFlagIsSignedInteger             = (1U << 2),     // 0x4
 kAudioFormatFlagIsPacked                    = (1U << 3),     // 0x8
 kAudioFormatFlagIsAlignedHigh               = (1U << 4),     // 0x10
 kAudioFormatFlagIsNonInterleaved            = (1U << 5),     // 0x20
 kAudioFormatFlagIsNonMixable                = (1U << 6),     // 0x40
 kAudioFormatFlagsAreAllClear                = 0x80000000,
 
 kLinearPCMFormatFlagIsFloat                 = kAudioFormatFlagIsFloat,
 kLinearPCMFormatFlagIsBigEndian             = kAudioFormatFlagIsBigEndian,
 kLinearPCMFormatFlagIsSignedInteger         = kAudioFormatFlagIsSignedInteger,
 kLinearPCMFormatFlagIsPacked                = kAudioFormatFlagIsPacked,
 kLinearPCMFormatFlagIsAlignedHigh           = kAudioFormatFlagIsAlignedHigh,
 kLinearPCMFormatFlagIsNonInterleaved        = kAudioFormatFlagIsNonInterleaved,
 kLinearPCMFormatFlagIsNonMixable            = kAudioFormatFlagIsNonMixable,
 kLinearPCMFormatFlagsSampleFractionShift    = 7,
 kLinearPCMFormatFlagsSampleFractionMask     = (0x3F << kLinearPCMFormatFlagsSampleFractionShift),
 kLinearPCMFormatFlagsAreAllClear            = kAudioFormatFlagsAreAllClear,
 
 kAppleLosslessFormatFlag_16BitSourceData    = 1,
 kAppleLosslessFormatFlag_20BitSourceData    = 2,
 kAppleLosslessFormatFlag_24BitSourceData    = 3,
 kAppleLosslessFormatFlag_32BitSourceData    = 4
 };
 */




typedef enum : NSUInteger {
    XBAudioFormatID_PCM = kAudioFormatLinearPCM,
} XBAudioFormatID;
/*
 CF_ENUM(AudioFormatID)
 {
 kAudioFormatLinearPCM               = 'lpcm',
 kAudioFormatAC3                     = 'ac-3',
 kAudioFormat60958AC3                = 'cac3',
 kAudioFormatAppleIMA4               = 'ima4',
 kAudioFormatMPEG4AAC                = 'aac ',
 kAudioFormatMPEG4CELP               = 'celp',
 kAudioFormatMPEG4HVXC               = 'hvxc',
 kAudioFormatMPEG4TwinVQ             = 'twvq',
 kAudioFormatMACE3                   = 'MAC3',
 kAudioFormatMACE6                   = 'MAC6',
 kAudioFormatULaw                    = 'ulaw',
 kAudioFormatALaw                    = 'alaw',
 kAudioFormatQDesign                 = 'QDMC',
 kAudioFormatQDesign2                = 'QDM2',
 kAudioFormatQUALCOMM                = 'Qclp',
 kAudioFormatMPEGLayer1              = '.mp1',
 kAudioFormatMPEGLayer2              = '.mp2',
 kAudioFormatMPEGLayer3              = '.mp3',
 kAudioFormatTimeCode                = 'time',
 kAudioFormatMIDIStream              = 'midi',
 kAudioFormatParameterValueStream    = 'apvs',
 kAudioFormatAppleLossless           = 'alac',
 kAudioFormatMPEG4AAC_HE             = 'aach',
 kAudioFormatMPEG4AAC_LD             = 'aacl',
 kAudioFormatMPEG4AAC_ELD            = 'aace',
 kAudioFormatMPEG4AAC_ELD_SBR        = 'aacf',
 kAudioFormatMPEG4AAC_ELD_V2         = 'aacg',
 kAudioFormatMPEG4AAC_HE_V2          = 'aacp',
 kAudioFormatMPEG4AAC_Spatial        = 'aacs',
 kAudioFormatAMR                     = 'samr',
 kAudioFormatAMR_WB                  = 'sawb',
 kAudioFormatAudible                 = 'AUDB',
 kAudioFormatiLBC                    = 'ilbc',
 kAudioFormatDVIIntelIMA             = 0x6D730011,
 kAudioFormatMicrosoftGSM            = 0x6D730031,
 kAudioFormatAES3                    = 'aes3',
 kAudioFormatEnhancedAC3             = 'ec-3',
 kAudioFormatFLAC                    = 'flac',
 kAudioFormatOpus                    = 'opus'
 };
 */



typedef enum : NSUInteger {
    XBAudioUnitPropertyID_callback_input = kAudioUnitProperty_SetRenderCallback, //设置输入回调(在回调里，是向ioData传递数据的)
    XBAudioUnitPropertyID_callback_output = kAudioOutputUnitProperty_SetInputCallback, //设置输出回调（在回调里，是用AudioUnitRender获取数据）
    XBAudioUnitPropertyID_StreamFormat = kAudioUnitProperty_StreamFormat, //设置数据流格式
    XBAudioUnitPropertyID_ElementCount = kAudioUnitProperty_ElementCount, //设置节点个数
} XBAudioUnitPropertyID;

/*
 CF_ENUM(AudioUnitPropertyID)
 {
 // range (0 -> 999)
 kAudioUnitProperty_ClassInfo                    = 0,
 kAudioUnitProperty_MakeConnection                = 1,
 kAudioUnitProperty_SampleRate                    = 2,
 kAudioUnitProperty_ParameterList                = 3,
 kAudioUnitProperty_ParameterInfo                = 4,
 kAudioUnitProperty_CPULoad                        = 6,
 kAudioUnitProperty_StreamFormat                    = 8,
 kAudioUnitProperty_ElementCount                    = 11,
 kAudioUnitProperty_Latency                        = 12,
 kAudioUnitProperty_SupportedNumChannels            = 13,
 kAudioUnitProperty_MaximumFramesPerSlice        = 14,
 kAudioUnitProperty_ParameterValueStrings        = 16,
 kAudioUnitProperty_AudioChannelLayout            = 19,
 kAudioUnitProperty_TailTime                        = 20,
 kAudioUnitProperty_BypassEffect                    = 21,
 kAudioUnitProperty_LastRenderError                = 22,
 kAudioUnitProperty_SetRenderCallback            = 23,
 kAudioUnitProperty_FactoryPresets                = 24,
 kAudioUnitProperty_RenderQuality                = 26,
 kAudioUnitProperty_HostCallbacks                = 27,
 kAudioUnitProperty_InPlaceProcessing            = 29,
 kAudioUnitProperty_ElementName                    = 30,
 kAudioUnitProperty_SupportedChannelLayoutTags    = 32,
 kAudioUnitProperty_PresentPreset                = 36,
 kAudioUnitProperty_DependentParameters            = 45,
 kAudioUnitProperty_InputSamplesInOutput            = 49,
 kAudioUnitProperty_ShouldAllocateBuffer            = 51,
 kAudioUnitProperty_FrequencyResponse            = 52,
 kAudioUnitProperty_ParameterHistoryInfo            = 53,
 kAudioUnitProperty_NickName                     = 54,
 kAudioUnitProperty_OfflineRender                = 37,
 kAudioUnitProperty_ParameterIDName                = 34,
 kAudioUnitProperty_ParameterStringFromValue        = 33,
 kAudioUnitProperty_ParameterClumpName            = 35,
 kAudioUnitProperty_ParameterValueFromString        = 38,
 kAudioUnitProperty_ContextName                    = 25,
 kAudioUnitProperty_PresentationLatency            = 40,
 kAudioUnitProperty_ClassInfoFromDocument        = 50,
 kAudioUnitProperty_RequestViewController        = 56,
 kAudioUnitProperty_ParametersForOverview        = 57,
 kAudioUnitProperty_SupportsMPE                    = 58,
 
 #if !TARGET_OS_IPHONE
 kAudioUnitProperty_FastDispatch                    = 5,
 kAudioUnitProperty_SetExternalBuffer            = 15,
 kAudioUnitProperty_GetUIComponentList            = 18,
 kAudioUnitProperty_CocoaUI                        = 31,
 kAudioUnitProperty_IconLocation                    = 39,
 kAudioUnitProperty_AUHostIdentifier                = 46,
 #endif
 
 kAudioUnitProperty_MIDIOutputCallbackInfo       = 47,
 kAudioUnitProperty_MIDIOutputCallback           = 48,
 };

 CF_ENUM(AudioUnitPropertyID) {
 kAudioOutputUnitProperty_CurrentDevice            = 2000,
 kAudioOutputUnitProperty_ChannelMap                = 2002, // this will also work with AUConverter
 kAudioOutputUnitProperty_EnableIO                = 2003,
 kAudioOutputUnitProperty_StartTime                = 2004,
 kAudioOutputUnitProperty_SetInputCallback        = 2005,
 kAudioOutputUnitProperty_HasIO                    = 2006,
 kAudioOutputUnitProperty_StartTimestampsAtZero  = 2007    // this will also work with AUConverter
 };
 
 */

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
