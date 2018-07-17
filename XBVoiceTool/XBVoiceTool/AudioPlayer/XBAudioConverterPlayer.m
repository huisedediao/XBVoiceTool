//
//  XBAudioConverterPlayer.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioConverterPlayer.h"
#import "XBAudioUnitPlayer.h"
#import "XBAudioTool.h"

@interface XBAudioConverterPlayer ()
{
    AudioFileID audioFileID;
    AudioStreamBasicDescription audioFileFormat;
    AudioStreamPacketDescription *audioPacketFormat;
    UInt64 packetNums;
    
    SInt64 readedPacket; // 已读的packet数量
    
    AudioBufferList *buffList;
    Byte *convertBuffer;
    
    AudioConverterRef audioConverter;
}
@property (nonatomic,strong) XBAudioUnitPlayer *player;
@end

@implementation XBAudioConverterPlayer
- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init])
    {
        [XBAudioTool getAudioPropertyWithFilepath:filePath completeBlock:^(AudioFileID audioFileIDT, AudioStreamBasicDescription audioFileFormatT, UInt64 packetNumsT, UInt64 maxFramesPerPacketT) {
            
            audioConverter = NULL;
            
            audioFileID = audioFileIDT;
            audioFileFormat = audioFileFormatT;
            packetNums = packetNumsT;
            
            readedPacket = 0;
            
            audioPacketFormat = malloc(sizeof(AudioStreamPacketDescription) * (CONST_BUFFER_SIZE / maxFramesPerPacketT + 1));
            
            buffList = [XBAudioTool allocAudioBufferListWithMDataByteSize:CONST_BUFFER_SIZE mNumberChannels:1 mNumberBuffers:1];
            
            convertBuffer = malloc(CONST_BUFFER_SIZE);
            
            int mFramesPerPacket = 1;
            int mBitsPerChannel = 32;
            int mChannelsPerFrame = 1;
            //输出格式
            AudioStreamBasicDescription outputFormat = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:kAudioFormatLinearPCM mFormatFlags:(kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved) mSampleRate:44100 mFramesPerPacket:mFramesPerPacket mChannelsPerFrame:mChannelsPerFrame mBitsPerChannel:mBitsPerChannel];
            
            [XBAudioTool printAudioStreamBasicDescription:audioFileFormat];
            [XBAudioTool printAudioStreamBasicDescription:outputFormat];
            
            CheckError(AudioConverterNew(&audioFileFormat, &outputFormat, &audioConverter), "AudioConverterNew eror");
            
            self.player = [[XBAudioUnitPlayer alloc] initWithRate:outputFormat.mSampleRate bit:outputFormat.mBitsPerChannel channel:outputFormat.mChannelsPerFrame];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"XBPCMPlayer销毁");
    [self stop];
    free(convertBuffer);
}
- (void)play
{
    if (self.player)
    {
        if (self.player.bl_input == nil)
        {
            typeof(self) __weak weakSelf = self;
            typeof(weakSelf) __strong strongSelf = weakSelf;
            self.player.bl_inputFull = ^(XBAudioUnitPlayer *player, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
                
                strongSelf->buffList->mBuffers[0].mDataByteSize = CONST_BUFFER_SIZE;
                OSStatus status = AudioConverterFillComplexBuffer(strongSelf->audioConverter, lyInInputDataProc, (__bridge void * _Nullable)(strongSelf), &inNumberFrames, strongSelf->buffList, NULL);
                if (status) {
                    NSLog(@"转换格式失败 %d", status);
                }
                
//                NSLog(@"out size: %d", strongSelf->buffList->mBuffers[0].mDataByteSize);
                memcpy(ioData->mBuffers[0].mData, strongSelf->buffList->mBuffers[0].mData, strongSelf->buffList->mBuffers[0].mDataByteSize);
                ioData->mBuffers[0].mDataByteSize = strongSelf->buffList->mBuffers[0].mDataByteSize;
                
                
                if (strongSelf->buffList->mBuffers[0].mDataByteSize <= 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [weakSelf stop];
                    });
                }
                
            };
        }
        [self.player start];
        self.isPlaying = YES;
    }
}
- (void)stop
{
    self.player.bl_input = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPreferredIOBufferDuration*0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player stop];
        self.isPlaying = NO;
    });
}
OSStatus lyInInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{
    XBAudioConverterPlayer *player = (__bridge XBAudioConverterPlayer *)(inUserData);
    
    UInt32 byteSize = CONST_BUFFER_SIZE;
    OSStatus status = AudioFileReadPacketData(player->audioFileID, NO, &byteSize, player->audioPacketFormat, player->readedPacket, ioNumberDataPackets, player->convertBuffer);
    
    if (outDataPacketDescription) { // 这里要设置好packetFormat，否则会转码失败
        *outDataPacketDescription = player->audioPacketFormat;
    }
    
    
    if(status) {
        NSLog(@"读取文件失败");
    }
    
    if (!status && ioNumberDataPackets > 0) {
        ioData->mBuffers[0].mDataByteSize = byteSize;
        ioData->mBuffers[0].mData = player->convertBuffer;
        player->readedPacket += *ioNumberDataPackets;
        return noErr;
    }
    else {
        return NO_MORE_DATA;
    }
    
}

- (double)getCurrentProgress
{
    Float64 timeInterval = (readedPacket * 1.0) / packetNums;
    return timeInterval;
}

@end
