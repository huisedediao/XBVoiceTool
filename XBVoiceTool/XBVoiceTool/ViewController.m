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

//#define stroePath [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"recordTest.caf"]

#define subPathPCM @"/Documents/xbMixData.caf"
//#define subPathPCM @"/Documents/xbMedia.caf"
#define stroePath [NSHomeDirectory() stringByAppendingString:subPathPCM]

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
    
//    [self playMP3New];
    
//    [self playMp3];
    
//    [self getFileProperty];
    
//    [self startMix];
    
//    [self record];
    
    [self play];
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

    AudioStreamBasicDescription desc = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:XBAudioFormatID_PCM mFormatFlags:(kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked) mSampleRate:XBAudioRate_44k mFramesPerPacket:1 mChannelsPerFrame:XBAudioChannel_1 mBitsPerChannel:XBAudioBit_16];
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
- (void)playMP3New
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
    self.mixer = [[XBAudioUnitMixerTest alloc] initWithPCMFilePath:path rate:XBAudioRate_44k channels:1 bit:16];
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
    
    self.palyer = [[XBPCMPlayer alloc] initWithPCMFilePath:path rate:XBAudioRate_44k channels:1 bit:16];
    
    self.palyer.delegate = self;
    [self.palyer play];
    NSLog(@"start Play");
}
- (void)delete
{
    NSString *pcmPath = stroePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pcmPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
    }
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

@end
