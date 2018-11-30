//
//  XBAudioUnitMixer.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/18.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioUnitMixer.h"
#import "XBAudioTool.h"
#import "XBAudioFileDataReader.h"
#import "XBDataWriter.h"
#import "XBExtAudioFileRef.h"

#define subPathPCM @"/Documents/xbMixMusic.caf"
#define stroePath [NSHomeDirectory() stringByAppendingString:subPathPCM]

@interface XBAudioUnitMixer ()
{
    AUGraph _auGraph;
    AudioUnit _mixUnit;
    AudioUnit _outputUnit;
    
    XBAudioFileDataReader *_dataReader;
}
@property (nonatomic,strong) XBDataWriter *dataWriter;
@property (nonatomic,strong) XBExtAudioFileRef *storeAudioFile;
@end

@implementation XBAudioUnitMixer

#pragma mark - 生命周期
- (instancetype)initWithFilePathArr:(NSArray *)filePathArr
{
    if (self = [super init])
    {
        _dataReader = [XBAudioFileDataReader new];
        [_dataReader loadFileToMemoryWithFilePathArr:filePathArr];

        [self createOutFile];
    }
    return self;
}

- (AudioStreamBasicDescription)getOutputFormat
{
    AudioStreamBasicDescription outputFormat = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:XBAudioFormatID_PCM mFormatFlags:(kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian) mSampleRate:XBAudioRate_44k mFramesPerPacket:1 mChannelsPerFrame:2 mBitsPerChannel:32];
    return outputFormat;
}

- (AudioStreamBasicDescription)getMixFormat
{
    AudioStreamBasicDescription mixStreamFmt = *([[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                                                  sampleRate:44100
                                                                                    channels:2
                                                                                 interleaved:NO].streamDescription);
    return mixStreamFmt;
}

- (void)createOutFile
{
    AudioStreamBasicDescription outputFormat = [self getOutputFormat];
    self.storeAudioFile = [[XBExtAudioFileRef alloc] initWithStorePath:stroePath inputFormat:&outputFormat];
}

- (void)initInputAudioUnitWithMixElementCount:(int)mixElementCount
{
    //创建和打开AUGraph，用于管理AUNode（AUNode包含AudioUnit）
    CheckError(NewAUGraph(&_auGraph), "newAuGraph failure");
    CheckError(AUGraphOpen(_auGraph), "openAuGraph failure");
    
    //创建outputUnit
    AudioComponentDescription outputDesc = [XBAudioTool allocAudioComponentDescriptionWithComponentType:kAudioUnitType_Output componentSubType:kAudioUnitSubType_RemoteIO componentFlags:0 componentFlagsMask:0];
    AUNode outputNode;
    CheckError(AUGraphAddNode(_auGraph, &outputDesc, &outputNode), "add outputNode failure");
    CheckError(AUGraphNodeInfo(_auGraph, outputNode, NULL, &_outputUnit), "NodeInfo for outputNode failure");
    
    //创建mixUnit
    AudioComponentDescription mixDesc = [XBAudioTool allocAudioComponentDescriptionWithComponentType:kAudioUnitType_Mixer componentSubType:kAudioUnitSubType_MultiChannelMixer componentFlags:0 componentFlagsMask:0];
    AUNode mixNode;
    CheckError(AUGraphAddNode(_auGraph, &mixDesc, &mixNode), "add mixNode failure");
    CheckError(AUGraphNodeInfo(_auGraph, mixNode, NULL, &_mixUnit), "NodeInfo for mixNode failure");
    
    //连接mixUnit的输出和outputUnit的输出
    CheckError(AUGraphConnectNodeInput(_auGraph, mixNode, 0, outputNode, 0), "AUGraphConnectNodeInput failure");
    
    
    //设置mixUnit的输入节点数量
    int inputElementCount = mixElementCount;
    CheckError(AudioUnitSetProperty(_mixUnit,
                                    XBAudioUnitPropertyID_ElementCount,
                                    kAudioUnitScope_Input,
                                    kInputBus,
                                    &inputElementCount,
                                    sizeof(inputElementCount)), "SetProperty ElementCount failure");
    
    for (int i = 0; i < mixElementCount; i++) {
        // setup render callback struct
        AURenderCallbackStruct callbackStr;
        callbackStr.inputProc = &mixerInputFun;
        callbackStr.inputProcRefCon = (__bridge void * _Nullable)(self);
        
        CheckError(AUGraphSetNodeInputCallback(_auGraph, mixNode, i, &callbackStr),
                   "set mixerNode callback error");
        
        
        AVAudioFormat *clientFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                                       sampleRate:kSmapleRate
                                                                         channels:_dataReader.getBufferList[i].channelCount
                                                                      interleaved:NO];
        CheckError(AudioUnitSetProperty(_mixUnit, kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input, i,
                                        clientFormat.streamDescription, sizeof(AudioStreamBasicDescription)),
                   "cant set the input scope format on bus[i]");
        
    }
    
    
    AudioStreamBasicDescription mixStreamFmt = [self getMixFormat];
    CheckError(AudioUnitSetProperty(_mixUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    0,
                                    &mixStreamFmt,
                                    sizeof(AudioStreamBasicDescription)),"set format failure");
    
    //play
    UInt32 size = sizeof(mixStreamFmt);
    CheckError(AudioUnitSetProperty(_outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &mixStreamFmt, size),"set format failure");
    
//    double sample = kSmapleRate;
//    CheckError(AudioUnitSetProperty(_mixUnit, kAudioUnitProperty_SampleRate,
//                                    kAudioUnitScope_Output, 0,&sample , sizeof(sample)),
//               "cant the mixer unit output sample");
    

    
    AudioStreamBasicDescription mixUnitOutputDesc;
    size = sizeof(mixUnitOutputDesc);
    CheckError(AudioUnitGetProperty(_mixUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    0,
                                    &mixUnitOutputDesc,
                                    &size),"get property failure");
    
    //play data callback
    CheckError(AudioUnitAddRenderNotify(_mixUnit, mixUnitOutputCallback, (__bridge void *)self),"AddRenderNotify mixUnitOutputCallback failure");
    
    //初始化AUGraph
    CheckError(AUGraphInitialize(_auGraph), "init AUGraph failure");
    CheckError(AUGraphStart(_auGraph), "start AUGraph failure");
}

- (void)dealloc
{
    [self pause];
    NSLog(@"XBAudioUnitMixer销毁");
}


#pragma mark - 控制
- (void)start
{
    if (_dataReader.endLoadFileToMemory)
    {
        [self initInputAudioUnitWithMixElementCount:(int)_dataReader.getBufferListLength];
        _isPlaying = YES;
    }
    else
    {
        NSLog(@"歌曲载入中...");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self start];
        });
    }
}

- (void)pause
{
    Boolean isRunning = false;
    
    CheckError(AUGraphIsRunning(_auGraph, &isRunning), "get AUGraphIsRunning info failure");
    
    if (isRunning)
    {
        CheckError(AUGraphStop(_auGraph), "stop graph failure");
        CheckError(AUGraphUninitialize(_auGraph),
                   "AUGraphUninitialize failed");
//        CheckError(AudioUnitRemoveRenderNotify(_mixUnit, mixUnitOutputCallback, (__bridge void *)self), "RemoveRenderNotify failure");
        _isPlaying = NO;
    }
}
- (void)enableInput:(BOOL)enable forBus:(int)busIndex
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CheckError(AudioUnitSetParameter(_mixUnit, kMultiChannelMixerParam_Enable,
                                         kAudioUnitScope_Input,
                                         busIndex,
                                         (AudioUnitParameterValue)enable,
                                         0),
                   "cant  set kMultiChannelMixerParam_Enable parameter") ;
    });
}
- (void)setInputVolumeValue:(CGFloat)value forBus:(int)busIndex
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CheckError(AudioUnitSetParameter(_mixUnit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Input,
                                         busIndex,
                                         (AudioUnitParameterValue)value,
                                         0),
                   "cant  set kMultiChannelMixerParam_Volume parameter in kAudioUnitScope_Input") ;
    });
}
- (void)setOutputVolumeValue:(AudioUnitParameterValue)value
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CheckError(AudioUnitSetParameter(_mixUnit,
                                         kMultiChannelMixerParam_Volume,
                                         kAudioUnitScope_Output,
                                         0,
                                         value,
                                         0),
                   "cant set kMultiChannelMixerParam_Volume parameter in kAudioUnitScope_Output");
    });
}


#pragma mark - 混音输入回调函数
static OSStatus mixerInputFun(void *inRefCon,
                              AudioUnitRenderActionFlags *ioActionFlags,
                              const AudioTimeStamp *inTimeStamp,
                              UInt32 inBusNumber,
                              UInt32 inNumberFrames,
                              AudioBufferList *ioData)
{
    XBAudioUnitMixer *mixer = (__bridge XBAudioUnitMixer *)inRefCon;
    XBAudioBuffer *buffer = &(mixer->_dataReader.getBufferList[inBusNumber]);

    UInt64 sample = buffer->startFrame;      // frame number to start from
    UInt64 bufSamples = buffer->totalFrames;  // total number of frames in the sound buffer
    Float32 *leftData = buffer->leftData; // audio data buffer
    Float32 *rightData = NULL;

    Float32 *outL = (Float32 *)ioData->mBuffers[0].mData; // output audio buffer for L channel
    Float32 *outR = NULL;
    if (buffer->channelCount == 2) {
        outR = (Float32 *)ioData->mBuffers[1].mData; //out audio buffer for R channel;
        rightData = buffer->rightData;
    }

    for (UInt32 i = 0; i < inNumberFrames; ++i) {
        outL[i] = leftData[sample];
        if (buffer->channelCount == 2) {
            outR[i] = rightData[sample];
        }
        sample++;

        if (sample > bufSamples) {
            // start over from the beginning of the data, our audio simply loops
            printf("looping data for bus %d after %ld source frames rendered\n", (unsigned int)inBusNumber, (long)sample-1);
            sample = 0;
        }
    }

    buffer->startFrame = sample; // keep track of where we are in the source data buffer
    
    return noErr;
}

static OSStatus mixUnitOutputCallback(void *inRefCon,
                                      
                                      AudioUnitRenderActionFlags *ioActionFlags,
                                      const AudioTimeStamp *inTimeStamp,
                                      UInt32 inBusNumber,
                                      UInt32 inNumberFrames,
                                      AudioBufferList *ioData) {
    
    XBAudioUnitMixer *mixer = (__bridge XBAudioUnitMixer *)inRefCon;
    //使用flag判断数据渲染前后，是渲染后状态则有数据可取
    if ((*ioActionFlags) & kAudioUnitRenderAction_PostRender)
    {
//        [mixer.storeAudioFile writeIoData:ioData inNumberFrames:inNumberFrames];
    }
    
    return noErr;
}
@end
