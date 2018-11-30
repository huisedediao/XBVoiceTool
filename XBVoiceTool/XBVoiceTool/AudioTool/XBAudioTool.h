//
//  XBAudioTool.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBAudioTool : NSObject
/** 同步获取文件信息
 filePath：          文件路径
 audioFileFormat ：  文件格式描述
 packetNums ：       总的packet数量
 maxFramesPerPacket：单个packet的最大帧数
 fileLengthFrames : 总帧数
 */
+ (void)getAudioPropertyWithFilepath:(NSString *)filePath completeBlock:(void (^)(AudioFileID audioFileID,AudioStreamBasicDescription audioFileFormat,UInt64 packetNums,UInt64 maxFramesPerPacket,UInt64 fileLengthFrames))completeBlock errorBlock:(void (^)(NSError *error))errorBlock;
/** 异步获取文件信息
 filePath：          文件路径
 audioFileFormat ：  文件格式描述
 packetNums ：       总的packet数量
 maxFramesPerPacket：单个packet的最大帧数
 fileLengthFrames : 总帧数
*/
+ (void)getAudioPropertyAsyncWithFilepath:(NSString *)filePath completeBlock:(void (^)(AudioFileID audioFileID,AudioStreamBasicDescription audioFileFormat,UInt64 packetNums,UInt64 maxFramesPerPacket,UInt64 fileLengthFrames))completeBlock errorBlock:(void (^)(NSError *error))errorBlock;
/**
 打印格式信息
 */
+ (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd;

/**
 创建AudioBufferList
 mDataByteSize ：AudioBuffer.mData （是一个Byte *数组） 数组长度
 mNumberChannels ：声道数
 mNumberBuffers ：AudioBuffer（mBuffers[1]） 数组的元素个数
 */
+ (AudioBufferList *)allocAudioBufferListWithMDataByteSize:(UInt32)mDataByteSize mNumberChannels:(UInt32)mNumberChannels mNumberBuffers:(UInt32)mNumberBuffers;

/**
 mSampleRate ： 采样率
 mFormatID ：格式
 mFormatFlags ： 不知道是啥
 mFramesPerPacket ： 每packet多少frames
 mChannelsPerFrame ： 每frame多少channel
 mBitsPerChannel ： 采样精度
 */
+ (AudioStreamBasicDescription)allocAudioStreamBasicDescriptionWithMFormatID:(XBAudioFormatID)mFormatID mFormatFlags:(XBAudioFormatFlags)mFormatFlags mSampleRate:(XBAudioRate)mSampleRate  mFramesPerPacket:(UInt32)mFramesPerPacket mChannelsPerFrame:(UInt32)mChannelsPerFrame mBitsPerChannel:(UInt32)mBitsPerChannel;

/**
 componentType : kAudioUnitType_
 componentSubType : kAudioUnitSubType_
 componentFlags : 0
 componentFlagsMask : 0
 */
+ (AudioComponentDescription)allocAudioComponentDescriptionWithComponentType:(OSType)componentType componentSubType:(OSType)componentSubType componentFlags:(UInt32)componentFlags componentFlagsMask:(UInt32)componentFlagsMask;
@end


/*
struct AudioBufferList
{
    UInt32      mNumberBuffers;
    AudioBuffer mBuffers[1]; // this is a variable length array of mNumberBuffers elements

#if defined(__cplusplus) && defined(CA_STRICT) && CA_STRICT
public:
    AudioBufferList() {}
private:
    //  Copying and assigning a variable length struct is problematic; generate a compile error.
    AudioBufferList(const AudioBufferList&);
    AudioBufferList&    operator=(const AudioBufferList&);
#endif

};
 */

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

/*
CF_ENUM(UInt32) {
    kAudioUnitType_Output                    = 'auou',
    kAudioUnitType_MusicDevice                = 'aumu',
    kAudioUnitType_MusicEffect                = 'aumf',
    kAudioUnitType_FormatConverter            = 'aufc',
    kAudioUnitType_Effect                    = 'aufx',
    kAudioUnitType_Mixer                    = 'aumx',
    kAudioUnitType_Panner                    = 'aupn',
    kAudioUnitType_Generator                = 'augn',
    kAudioUnitType_OfflineEffect            = 'auol',
    kAudioUnitType_MIDIProcessor            = 'aumi'
    };
 */
