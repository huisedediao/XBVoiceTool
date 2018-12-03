//
//  ViewController.m
//  XBVoiceTool
//
//  Created by xxb on 2018/6/20.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "ViewController.h"
#import "XBPCMPlayer.h"
#import "XBAudioFormatConversion.h"
#import "XBAudioUnitRecorder.h"
#import "XBAudioUnitMixerTest.h"
#import "XBAudioTool.h"
#import "XBAudioConverterPlayer.h"
#import "XBAudioPlayer.h"
#import "XBAudioUnitMixer.h"
#import "XBAudioPCMDataReader.h"
#import "XBAudioFileDataReader.h"
#import "XBExtAudioFileRef.h"
#import "ExtAudioFileMixer.h"
#import "XBDataWriter.h"
#import "XBAACEncoder_system.h"
#import "MP3Encoder.h"

//#define stroePath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"recordTest.caf"]

#define subPathPCM @"/Documents/xbMixData.caf"
//#define subPathPCM @"/Documents/xbMedia.caf"
#define stroePath [NSHomeDirectory() stringByAppendingString:subPathPCM]

#define aacStroePath [NSHomeDirectory() stringByAppendingString:@"/Documents/testAAC.aac"]
#define mp3StroePath [NSHomeDirectory() stringByAppendingString:@"/Documents/testMP3.mp3"]

@interface ViewController () <XBPCMPlayerDelegate>
@property (nonatomic,strong) XBPCMPlayer *palyer;
@property (nonatomic,strong) XBAudioUnitRecorder *recorder;
@property (nonatomic,strong) XBAudioUnitMixerTest *mixer;
@property (nonatomic,strong) XBAudioConverterPlayer *audioPlayer;
@property (nonatomic,strong) XBAudioPlayer *audioPlayerNew;
@property (nonatomic,strong) XBAudioUnitMixer *musicMixer;
//@property (nonatomic,strong) XBAudioPCMDataReader *dataReader;
@property (nonatomic,strong) XBExtAudioFileRef *xbFile;
@property (nonatomic,strong) XBDataWriter *dataWriter;
@property (nonatomic,strong) XBAACEncoder_system *aacEncoder;
@property (nonatomic,strong) MP3Encoder *mp3Encoder;
@end

@implementation ViewController
- (IBAction)playBtnClick:(UIButton *)sender
{
    [self.musicMixer pause];
//    [self.recorder stop];
    [self play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self mixMusicTest];
    
//    [self writeTest];
    
//    [self mixMusic];
    
//    [self playAACNew];
    
//    [self playMp3];
    
//    [self getFileProperty];
    
//    [self startMix];
    
//    [self record];
    
//    [self play];
    
//    [self aacEncodeTest];
    
    [self mp3EncodeTest];
}

#pragma mark - mp3编码
- (void)mp3EncodeTest
{
    [self deleteFileAtPath:mp3StroePath];
    
    self.recorder = [[XBAudioUnitRecorder alloc] initWithRate:XBAudioRate_44k bit:XBAudioBit_16 channel:XBAudioChannel_1];
    
    _mp3Encoder = [[MP3Encoder alloc] initWithSampleRate:XBAudioRate_44k channels:1 bitRate:128];
    
    self.dataWriter = [[XBDataWriter alloc] init];
    
    typeof(self) __weak weakSelf = self;
    self.recorder.bl_output = ^(AudioBufferList *bufferList) {
        AudioBuffer buffer = bufferList->mBuffers[0];
        [weakSelf.mp3Encoder encodePCMData:buffer.mData len:buffer.mDataByteSize completeBlock:^(unsigned char *encodedData, int len) {
            [weakSelf.dataWriter writeBytes:encodedData len:len toPath:mp3StroePath];
        }];
    };
    [self.recorder start];
}

#pragma mark - aac编码
- (void)aacEncodeTest
{
    [self deleteFileAtPath:aacStroePath];
    
    self.recorder = [[XBAudioUnitRecorder alloc] initWithRate:XBAudioRate_44k bit:XBAudioBit_16 channel:XBAudioChannel_1];
    AudioStreamBasicDescription encoderInputDesc = [self.recorder getOutputFormat];
    self.aacEncoder = [[XBAACEncoder_system alloc] initWithInputAudioStreamDesc:encoderInputDesc];
    
    self.dataWriter = [[XBDataWriter alloc] init];
    
    typeof(self) __weak weakSelf = self;
    self.recorder.bl_output = ^(AudioBufferList *bufferList) {
        AudioBuffer buffer = bufferList->mBuffers[0];
        [weakSelf.aacEncoder encodePCMData:buffer.mData len:buffer.mDataByteSize completionBlock:^(NSData *encodedData, NSError *error) {
            [weakSelf.dataWriter writeData:encodedData toPath:aacStroePath];
        }];
    };
    [self.recorder start];
}

#pragma mark - mixTest
- (void)mixMusicTest
{
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"周杰伦 - 晴天" ofType:@"mp3"];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"几个你_薛之谦" ofType:@"aac"];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"胡彦斌 - 为你我受冷风吹" ofType:@"mp3"];
    [ExtAudioFileMixer mixAudio:filePath1 andAudio:filePath2 toFile:stroePath preferedSampleRate:kSmapleRate];
}

#pragma mark - 测试文件写入
- (void)writeTest
{
    [self delete];
    self.recorder = [[XBAudioUnitRecorder alloc] initWithRate:XBAudioRate_44k bit:XBAudioBit_16 channel:XBAudioChannel_1];

    AudioStreamBasicDescription desc = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:XBAudioFormatID_PCM mFormatFlags:(XBAudioFormatFlags)(kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked) mSampleRate:XBAudioRate_44k mFramesPerPacket:1 mChannelsPerFrame:XBAudioChannel_1 mBitsPerChannel:XBAudioBit_16];
    self.xbFile = [[XBExtAudioFileRef alloc] initWithStorePath:stroePath inputFormat:&desc];
    
    typeof(self) __weak weakSelf = self;

    self.recorder.bl_outputFull = ^(XBAudioUnitRecorder *player, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
        [weakSelf.xbFile writeIoData:ioData inNumberFrames:inNumberFrames];
    };
    [self.recorder start];
    
}




#pragma mark - 混音
- (void)mixMusic
{
    [self delete];
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"周杰伦 - 晴天" ofType:@"mp3"];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"几个你_薛之谦" ofType:@"aac"];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"胡彦斌 - 为你我受冷风吹" ofType:@"mp3"];
    self.musicMixer = [[XBAudioUnitMixer alloc] initWithFilePathArr:@[filePath1,filePath2]];
    [self.musicMixer start];
}



#pragma mark - 播放mp3
///通过ExtAudioFileRead
- (void)playAACNew
{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"周杰伦 - 晴天" ofType:@"mp3"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"几个你_薛之谦" ofType:@"aac"];
    self.audioPlayerNew = [[XBAudioPlayer alloc] initWithFilePath:filePath];
    [self.audioPlayerNew start];
}

///经过AudioConverter转换
- (void)playMp3
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"周杰伦 - 晴天" ofType:@"mp3"];
    self.audioPlayer = [[XBAudioConverterPlayer alloc] initWithFilePath:filePath];
    [self.audioPlayer play];
}

#pragma mark - 读取文件格式
- (void)getFileProperty
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"周杰伦 - 晴天" ofType:@"mp3"];
    [XBAudioTool getAudioPropertyWithFilepath:filePath completeBlock:^(AudioFileID audioFileID,AudioStreamBasicDescription audioFileFormat, UInt64 packetNums, UInt64 maxFramesPerPacket, UInt64 fileLengthFrames) {
        
    } errorBlock:^(NSError *error) {
        
    }];
}

#pragma mark - 麦克风输入和PCM数据混音
- (void)startMix
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"pcm"];
    self.mixer = [[XBAudioUnitMixerTest alloc] initWithPCMFilePath:path rate:XBAudioRate_44k channels:(XBAudioChannel)1 bit:(XBAudioBit)16];
    [self.mixer start];
}

- (void)stopMix
{
    [self.mixer stop];
    self.mixer = nil;
}

#pragma mark - 录音
- (void)record
{
    self.recorder = [XBAudioUnitRecorder new];
    [self.recorder start];
}

- (void)stopRecord
{
    [self.recorder stop];
    self.recorder = nil;
}

#pragma mark - 播放
- (void)play
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"pcm"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"xbMixMusicTest" ofType:@"caf"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"output" ofType:@"pcm"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testDecode" ofType:@"pcm"];
//    NSString *path = stroePath;
    
    self.palyer = [[XBPCMPlayer alloc] initWithPCMFilePath:path rate:XBAudioRate_44k channels:(XBAudioChannel)1 bit:(XBAudioBit)16];
    
    self.palyer.delegate = self;
    [self.palyer play];
    NSLog(@"start Play");
}
- (void)delete
{
    [self deleteFileAtPath:stroePath];
}

- (void)stopPlay
{
    [self.palyer stop];
    self.palyer = nil;
}

- (void)playToEnd:(XBPCMPlayer *)player
{
    NSLog(@"end play");
    self.palyer = nil;
}

- (void)deleteFileAtPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}
@end
