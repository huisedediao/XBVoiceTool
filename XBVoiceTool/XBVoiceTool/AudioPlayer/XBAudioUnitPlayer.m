//
//  XBAudioUnitPlayer.m
//  XBVoiceTool
//
//  Created by xxb on 2018/6/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioUnitPlayer.h"
#import "XBAudioTool.h"

@interface XBAudioUnitPlayer ()
{
    AudioUnit audioUnit;
}
@property (nonatomic,assign) XBAudioBit bit;
@property (nonatomic,assign) XBAudioRate rate;
@property (nonatomic,assign) XBAudioChannel channel;
@end

@implementation XBAudioUnitPlayer

- (instancetype)initWithRate:(XBAudioRate)rate bit:(XBAudioBit)bit channel:(XBAudioChannel)channel
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
        self.rate = XBAudioRate_44k;
        self.bit = XBAudioBit_16;
        self.channel = XBAudioChannel_1;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"XBAudioUnitPlayer销毁");
}

- (void)initAudioUnitWithRate:(XBAudioRate)rate bit:(XBAudioBit)bit channel:(XBAudioChannel)channel
{
    //设置session
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    //初始化audioUnit
    AudioComponentDescription outputDesc = [XBAudioTool allocAudioComponentDescriptionWithComponentType:kAudioUnitType_Output componentSubType:kAudioUnitSubType_VoiceProcessingIO componentFlags:0 componentFlagsMask:0];
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &outputDesc);
    AudioComponentInstanceNew(outputComponent, &audioUnit);
    

    
    //设置输出格式
    int mFramesPerPacket = 1;
    
    AudioStreamBasicDescription streamDesc = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:kAudioFormatLinearPCM mFormatFlags:(kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved) mSampleRate:rate mFramesPerPacket:mFramesPerPacket mChannelsPerFrame:channel mBitsPerChannel:bit];
    
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
    typeof(player) __weak weakPlayer = player;
    if (player.bl_input)
    {
        player.bl_input(ioData);
    }
    if (player.bl_inputFull)
    {
        player.bl_inputFull(weakPlayer, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    }
    return noErr;
}

@end
