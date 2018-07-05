//
//  XBAudioUnitRecorder.m
//  XBVoiceTool
//
//  Created by xxb on 2018/6/28.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioUnitRecorder.h"

#define subPathPCM @"/Documents/xbMedia"
#define stroePath [NSHomeDirectory() stringByAppendingString:subPathPCM]

@interface XBAudioUnitRecorder ()
{
    AudioUnit audioUnit;
}
@property (nonatomic,assign) XBVoiceBit bit;
@property (nonatomic,assign) XBVoiceRate rate;
@property (nonatomic,assign) XBVoiceChannel channel;
@end

@implementation XBAudioUnitRecorder

- (instancetype)initWithRate:(XBVoiceRate)rate bit:(XBVoiceBit)bit channel:(XBVoiceChannel)channel
{
    if (self = [super init])
    {
        self.bit = bit;
        self.rate = rate;
        self.channel = channel;
    }
    return self;
}
- (instancetype)init
{
    if (self = [super init])
    {
        self.bit = XBVoiceBit_16;
        self.rate = XBVoiceRate_44k;
        self.channel = XBVoiceChannel_1;
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"XBAudioUnitRecorder销毁");
}

- (void)initInputAudioUnitWithRate:(XBVoiceRate)rate bit:(XBVoiceBit)bit channel:(XBVoiceChannel)channel
{
    //设置AVAudioSession
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    //初始化audioUnit
    AudioComponentDescription inputDesc;
    inputDesc.componentType = kAudioUnitType_Output;
    inputDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    inputDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    inputDesc.componentFlags = 0;
    inputDesc.componentFlagsMask = 0;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &inputDesc);
    AudioComponentInstanceNew(inputComponent, &audioUnit);
    

    //设置输出流格式
    int mFramesPerPacket = 1;
    int mBytesPerFrame = bit * channel / 8;
    
    AudioStreamBasicDescription inputStreamDesc;
    inputStreamDesc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsPacked;
    inputStreamDesc.mFormatID = kAudioFormatLinearPCM;
    inputStreamDesc.mSampleRate = rate;
    inputStreamDesc.mFramesPerPacket = mFramesPerPacket;
    inputStreamDesc.mBitsPerChannel = bit;
    inputStreamDesc.mChannelsPerFrame = channel;
    inputStreamDesc.mBytesPerFrame = mBytesPerFrame;
    inputStreamDesc.mBytesPerPacket = mFramesPerPacket *  mBytesPerFrame;
    
    OSStatus status = AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         kInputBus,
                         &inputStreamDesc,
                         sizeof(inputStreamDesc));
    CheckError(status, "setProperty StreamFormat error");
    
    //麦克风输入设置为1（yes）
    int inputEnable = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &inputEnable,
                                  sizeof(inputEnable));
    CheckError(status, "setProperty EnableIO error");
    
    //设置回调
    AURenderCallbackStruct inputCallBackStruce;
    inputCallBackStruce.inputProc = inputCallBackFun;
    inputCallBackStruce.inputProcRefCon = (__bridge void * _Nullable)(self);
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &inputCallBackStruce,
                                  sizeof(inputCallBackStruce));
    CheckError(status, "setProperty InputCallback error");
}

- (void)start
{
    [self delete];
    [self initInputAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
    AudioOutputUnitStart(audioUnit);
}

- (void)stop
{
    CheckError(AudioOutputUnitStop(audioUnit),
               "AudioOutputUnitStop failed");
    CheckError(AudioComponentInstanceDispose(audioUnit),
               "AudioComponentInstanceDispose failed");
}

static OSStatus inputCallBackFun(    void *                            inRefCon,
                    AudioUnitRenderActionFlags *    ioActionFlags,
                    const AudioTimeStamp *            inTimeStamp,
                    UInt32                            inBusNumber,
                    UInt32                            inNumberFrames,
                    AudioBufferList * __nullable    ioData)
{

    XBAudioUnitRecorder *recorder = (__bridge XBAudioUnitRecorder *)(inRefCon);
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    
    AudioUnitRender(recorder->audioUnit,
                    ioActionFlags,
                    inTimeStamp,
                    kInputBus,
                    inNumberFrames,
                    &bufferList);
    
    if (recorder.bl_output)
    {
        recorder.bl_output(&bufferList);
    }
    
//    AudioBuffer buffer = bufferList.mBuffers[0];
//    NSData *pcmBlock = [NSData dataWithBytes:buffer.mData length:buffer.mDataByteSize];
//
//    NSLog(@"------->>数据%@",pcmBlock);
//    NSString *savePath = stroePath;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath] == false)
//    {
//        [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
//    }
//    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:savePath];
//    [handle seekToEndOfFile];
//    [handle writeData:pcmBlock];
    
    return noErr;
}
- (void)delete
{
    NSString *pcmPath = stroePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pcmPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
    }
}
@end
