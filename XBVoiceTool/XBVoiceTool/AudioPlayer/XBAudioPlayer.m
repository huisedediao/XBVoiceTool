//
//  XBAudioPlayer.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/10.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioPlayer.h"
#import "XBAudioUnitPlayer.h"
#import "XBAudioTool.h"

@interface XBAudioPlayer ()
{
    ExtAudioFileRef _audioFile;
    XBAudioUnitPlayer *_player;
    AudioBufferList *_bufferList;
    AudioStreamBasicDescription _outputFormat;
    UInt64 _totalFrame;
    UInt64 _readedFrame;
}
@end

@implementation XBAudioPlayer
- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (self == [super init])
    {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        CheckError(ExtAudioFileOpenURL((__bridge CFURLRef)url, &_audioFile),"打开文件失败");
        
        _bufferList = [XBAudioTool allocAudioBufferListWithMDataByteSize:CONST_BUFFER_SIZE mNumberChannels:1 mNumberBuffers:1];
        
        _outputFormat = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:kAudioFormatLinearPCM mFormatFlags:kLinearPCMFormatFlagIsSignedInteger mSampleRate:XBAudioRate_44k mFramesPerPacket:1 mChannelsPerFrame:2 mBitsPerChannel:16];
        
        uint size = sizeof(_outputFormat);
        CheckError(ExtAudioFileSetProperty(_audioFile, kExtAudioFileProperty_ClientDataFormat, size, &_outputFormat), "setkExtAudioFileProperty_ClientDataFormat failure");
        
        size = sizeof(_totalFrame);
        CheckError(ExtAudioFileGetProperty(_audioFile,
                                           kExtAudioFileProperty_FileLengthFrames,
                                           &size,
                                           &_totalFrame), "获取总帧数失败");
        _readedFrame = 0;
    }
    return self;
}
- (void)start
{
    if (_player == nil)
    {
        typeof(self) __weak weakSelf = self;
        typeof(self) __strong strongSelf = weakSelf;
        _player = [[XBAudioUnitPlayer alloc] initWithRate:_outputFormat.mSampleRate bit:_outputFormat.mBitsPerChannel channel:_outputFormat.mChannelsPerFrame];
        _player.bl_inputFull = ^(XBAudioUnitPlayer *player, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
            strongSelf->_bufferList->mBuffers[0].mDataByteSize = CONST_BUFFER_SIZE;
            OSStatus status = ExtAudioFileRead(strongSelf->_audioFile, &inNumberFrames, strongSelf->_bufferList);
            memcpy(ioData->mBuffers[0].mData, strongSelf->_bufferList->mBuffers[0].mData, strongSelf->_bufferList->mBuffers[0].mDataByteSize);
            ioData->mBuffers[0].mDataByteSize = strongSelf->_bufferList->mBuffers[0].mDataByteSize;
            if (ioData->mBuffers[0].mDataByteSize == 0)
            {
                [weakSelf stop];
            }
            strongSelf->_readedFrame += ioData->mBuffers[0].mDataByteSize / strongSelf->_outputFormat.mBytesPerFrame;
            CheckError(status, "转换格式失败");
            if (inNumberFrames == 0) NSLog(@"播放结束");
            
            NSLog(@"%f",[strongSelf getProgress]);
        };
    }
    [_player start];
}
- (void)stop
{
    _player.bl_input = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player stop];
        _player = nil;
    });
}

- (float)getProgress
{
    return _readedFrame * 1.0 / _totalFrame;
}
@end
