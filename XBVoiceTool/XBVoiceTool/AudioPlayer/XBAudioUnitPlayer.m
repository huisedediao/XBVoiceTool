//
//  XBAudioUnitPlayer.m
//  XBVoiceTool
//
//  Created by xxb on 2018/6/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioUnitPlayer.h"

@interface XBAudioUnitPlayer ()
{
    AudioUnit audioUnit;
}
@property (nonatomic,assign) XBVoiceBit bit;
@property (nonatomic,assign) XBVoiceRate rate;
@property (nonatomic,assign) XBVoiceChannel channel;
@end

@implementation XBAudioUnitPlayer

- (instancetype)initWithRate:(XBVoiceRate)rate bit:(XBVoiceBit)bit channel:(XBVoiceChannel)channel
{
    if (self = [super init])
    {
        self.rate = rate;
        self.bit = bit;
        self.channel = channel;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.rate = XBVoiceRate_44k;
        self.bit = XBVoiceBit_16;
        self.channel = XBVoiceChannel_1;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"XBAudioUnitPlayer销毁");
}

- (void)initAudioUnitWithRate:(XBVoiceRate)rate bit:(XBVoiceBit)bit channel:(XBVoiceChannel)channel
{
    //设置session
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    //初始化audioUnit
    AudioComponentDescription outputDesc;
    outputDesc.componentType = kAudioUnitType_Output;
    outputDesc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    outputDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDesc.componentFlags = 0;
    outputDesc.componentFlagsMask = 0;
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &outputDesc);
    AudioComponentInstanceNew(outputComponent, &audioUnit);
    

    
    //设置输出格式
    int mFramesPerPacket = 1;
    int mBytesPerFrame = channel * bit / 8;
    
    AudioStreamBasicDescription streamDesc;
    streamDesc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved;
    streamDesc.mFormatID = kAudioFormatLinearPCM;
    streamDesc.mSampleRate = rate;
    streamDesc.mFramesPerPacket = mFramesPerPacket;
    streamDesc.mChannelsPerFrame = channel;
    streamDesc.mBitsPerChannel = bit;
    streamDesc.mBytesPerFrame = mBytesPerFrame;
    streamDesc.mBytesPerPacket = mBytesPerFrame * mFramesPerPacket;
    
    OSStatus status = AudioUnitSetProperty(audioUnit,
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Input,
                                           kOutputBus,
                                           &streamDesc,
                                           sizeof(streamDesc));
    CheckError(status, "SetProperty StreamFormat failure");
    
    //设置回调
    AURenderCallbackStruct outputCallBackStruct;
    outputCallBackStruct.inputProc = outputCallBackFun;
    outputCallBackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &outputCallBackStruct,
                                  sizeof(outputCallBackStruct));
    CheckError(status, "SetProperty EnableIO failure");
}


- (void)start
{
    [self initAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
    AudioOutputUnitStart(audioUnit);
}

- (void)stop
{
    OSStatus status;
    status = AudioOutputUnitStop(audioUnit);
    CheckError(status, "audioUnit停止失败");

    status = AudioComponentInstanceDispose(audioUnit);
    CheckError(status, "audioUnit释放失败");
}
static OSStatus outputCallBackFun(    void *                            inRefCon,
                    AudioUnitRenderActionFlags *    ioActionFlags,
                    const AudioTimeStamp *            inTimeStamp,
                    UInt32                            inBusNumber,
                    UInt32                            inNumberFrames,
                    AudioBufferList * __nullable    ioData)
{
    memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
//    memset(ioData->mBuffers[1].mData, 0, ioData->mBuffers[1].mDataByteSize);
    
    XBAudioUnitPlayer *player = (__bridge XBAudioUnitPlayer *)(inRefCon);
    if (player.bl_input)
    {
        player.bl_input(ioData);
    }
    return noErr;
}

@end
