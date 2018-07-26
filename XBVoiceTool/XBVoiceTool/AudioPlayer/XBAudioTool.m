//
//  XBAudioTool.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioTool.h"

@implementation XBAudioTool
/** 同步获取文件信息
 filePath：          文件路径
 audioFileFormat ：  文件格式描述
 packetNums ：       总的packet数量
 maxFramesPerPacket：单个packet的最大帧数
 fileLengthFrames : 总帧数
 */
+ (void)getAudioPropertyWithFilepath:(NSString *)filePath completeBlock:(void (^)(AudioFileID audioFileID,AudioStreamBasicDescription audioFileFormat,UInt64 packetNums,UInt64 maxFramesPerPacket,UInt64 fileLengthFrames))completeBlock errorBlock:(void (^)(NSError *error))errorBlock
{
    AudioFileID audioFileID;
    AudioStreamBasicDescription audioFileFormat = {};
    UInt64 packetNums = 0;
    UInt64 maxFramesPerPacket = 0;
    NSError *error;
    
    //打开文件
    NSURL *url = [NSURL fileURLWithPath:filePath];
    OSStatus status = AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &audioFileID);
    if (status != noErr)
    {
        NSLog(@"打开文件失败 %@", url);
        error = [NSError errorWithDomain:@"打开文件失败" code:1008601 userInfo:nil];
        if (errorBlock)
        {
            errorBlock(error);
        }
        return;
    }
    
    //读取文件格式
    uint32_t size = sizeof(AudioStreamBasicDescription);
    status = AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &size, &audioFileFormat);
    if (status != noErr)
    {
        error = [NSError errorWithDomain:[NSString stringWithFormat:@"读取文件格式出错，error status %zd", status] code:1008602 userInfo:nil];
        if (errorBlock)
        {
            errorBlock(error);
        }
        return;
    }
    
    //读取文件总的packet数量
    size = sizeof(packetNums);
    status = AudioFileGetProperty(audioFileID,
                                  kAudioFilePropertyAudioDataPacketCount,
                                  &size,
                                  &packetNums);
    if (error != noErr)
    {
        error = [NSError errorWithDomain:[NSString stringWithFormat:@"读取文件packets总数出错，error status %zd", status] code:1008603 userInfo:nil];
        if (errorBlock)
        {
            errorBlock(error);
        }
        return;
    }
    
    // 读取单个packet的最大帧数
    maxFramesPerPacket = audioFileFormat.mFramesPerPacket;
    if (maxFramesPerPacket == 0) {
        size = sizeof(maxFramesPerPacket);
        status = AudioFileGetProperty(audioFileID, kAudioFilePropertyMaximumPacketSize, &size, &maxFramesPerPacket);
        if (status != noErr)
        {
            error = [NSError errorWithDomain:[NSString stringWithFormat:@"读取单个packet的最大数量出错，error status %zd", status] code:1008604 userInfo:nil];
            if (errorBlock)
            {
                errorBlock(error);
            }
            return;
        }
        if(status ==noErr && maxFramesPerPacket == 0)
        {
            error = [NSError errorWithDomain:@"AudioFileGetProperty error or sizePerPacket = 0" code:1008605 userInfo:nil];
            if (errorBlock)
            {
                errorBlock(error);
            }
            return;
        }
    }
    
    // 总帧数
    UInt64 numFrames = maxFramesPerPacket * packetNums;
    
    AudioFileClose(audioFileID);
    
    if (completeBlock)
    {
        completeBlock(audioFileID,audioFileFormat,packetNums,maxFramesPerPacket,numFrames);
    }
}
/** 异步获取文件信息
 filePath：          文件路径
 audioFileFormat ：  文件格式描述
 packetNums ：       总的packet数量
 maxFramesPerPacket：单个packet的最大帧数
 fileLengthFrames : 总帧数
 */
+ (void)getAudioPropertyAsyncWithFilepath:(NSString *)filePath completeBlock:(void (^)(AudioFileID audioFileID,AudioStreamBasicDescription audioFileFormat,UInt64 packetNums,UInt64 maxFramesPerPacket,UInt64 fileLengthFrames))completeBlock errorBlock:(void (^)(NSError *error))errorBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XBAudioTool getAudioPropertyWithFilepath:filePath completeBlock:^(AudioFileID audioFileID, AudioStreamBasicDescription audioFileFormat, UInt64 packetNums, UInt64 maxFramesPerPacket, UInt64 fileLengthFrames) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completeBlock)
                {
                    completeBlock(audioFileID,audioFileFormat,packetNums,maxFramesPerPacket,fileLengthFrames);
                }
            });
        } errorBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errorBlock)
                {
                    errorBlock(error);
                }
            });
        }];
    });
}

+ (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
{
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("Sample Rate:         %10.0f\n",  asbd.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)asbd.mBytesPerPacket);
    printf("Frames per Packet:   %10d\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("Channels per Frame:  %10d\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)asbd.mBitsPerChannel);
    printf("\n");
}

/**
 创建AudioBufferList
 mDataByteSize ：AudioBuffer.mData （是一个Byte *数组） 数组长度
 mNumberChannels ：声道数
 mNumberBuffers ：AudioBuffer（mBuffers[1]） 数组的元素个数
 */
+ (AudioBufferList *)allocAudioBufferListWithMDataByteSize:(UInt32)mDataByteSize mNumberChannels:(UInt32)mNumberChannels mNumberBuffers:(UInt32)mNumberBuffers
{
    AudioBufferList *_bufferList;
    _bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    _bufferList->mNumberBuffers = 1;
    _bufferList->mBuffers[0].mData = malloc(mDataByteSize);
    _bufferList->mBuffers[0].mDataByteSize = mDataByteSize;
    _bufferList->mBuffers[0].mNumberChannels = 1;
    return _bufferList;
}

/**
 mSampleRate ： 采样率
 mFormatID ：格式
 mFormatFlags ： 不知道是啥
 mFramesPerPacket ： 每packet多少frames
 mChannelsPerFrame ： 每frame多少channel
 mBitsPerChannel ： 采样精度
 */
+ (AudioStreamBasicDescription)allocAudioStreamBasicDescriptionWithMFormatID:(XBAudioFormatID)mFormatID mFormatFlags:(XBAudioFormatFlags)mFormatFlags mSampleRate:(XBAudioRate)mSampleRate  mFramesPerPacket:(UInt32)mFramesPerPacket mChannelsPerFrame:(UInt32)mChannelsPerFrame mBitsPerChannel:(UInt32)mBitsPerChannel
{
    AudioStreamBasicDescription _outputFormat;
    memset(&_outputFormat, 0, sizeof(_outputFormat));
    _outputFormat.mSampleRate       = mSampleRate;
    _outputFormat.mFormatID         = mFormatID;
    _outputFormat.mFormatFlags      = mFormatFlags;
    _outputFormat.mFramesPerPacket  = mFramesPerPacket;
    _outputFormat.mChannelsPerFrame = mChannelsPerFrame;
    _outputFormat.mBitsPerChannel   = mBitsPerChannel;
    _outputFormat.mBytesPerFrame    = mBitsPerChannel * mChannelsPerFrame / 8;
    _outputFormat.mBytesPerPacket   = mBitsPerChannel * mChannelsPerFrame / 8 * mFramesPerPacket;
    return _outputFormat;
}

/**
 componentType : kAudioUnitType_
 componentSubType : kAudioUnitSubType_
 componentFlags : 0
 componentFlagsMask : 0
*/
+ (AudioComponentDescription)allocAudioComponentDescriptionWithComponentType:(OSType)componentType componentSubType:(OSType)componentSubType componentFlags:(UInt32)componentFlags componentFlagsMask:(UInt32)componentFlagsMask
{
    AudioComponentDescription outputDesc;
    outputDesc.componentType = componentType;
    outputDesc.componentSubType = componentSubType;
    outputDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDesc.componentFlags = componentFlags;
    outputDesc.componentFlagsMask = componentFlagsMask;
    return outputDesc;
}
@end
