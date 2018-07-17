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
#import "XBAudioUnitMixer.h"
#import "XBAudioTool.h"
#import "XBAudioConverterPlayer.h"
#import "XBAudioPlayer.h"

@interface ViewController () <XBPCMPlayerDelegate>
@property (nonatomic,strong) XBPCMPlayer *palyer;
@property (nonatomic,strong) XBAudioUnitRecorder *recorder;
@property (nonatomic,strong) XBAudioUnitMixer *mixer;
@property (nonatomic,strong) XBAudioConverterPlayer *audioPlayer;
@property (nonatomic,strong) XBAudioPlayer *audioPlayerNew;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self playMP3New];
    
//    [self playMp3];
    
//    [self getFileProperty];
    
//    [self startMix];
    
//    [self record];
    
//    [self play];
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
    [XBAudioTool getAudioPropertyWithFilepath:filePath completeBlock:^(AudioFileID audioFileID,AudioStreamBasicDescription audioFileFormat, UInt64 packetNums, UInt64 maxFramesPerPacket) {
        
    } errorBlock:^(NSError *error) {
        
    }];
}

#pragma mark - 麦克风输入和PCM数据混音
- (void)startMix
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"pcm"];
    self.mixer = [[XBAudioUnitMixer alloc] initWithPCMFilePath:path rate:XBVoiceRate_44k channels:1 bit:16];
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"pcm"];
    self.palyer = [[XBPCMPlayer alloc] initWithPCMFilePath:path rate:XBVoiceRate_44k channels:1 bit:16];
    
    self.palyer.delegate = self;
    [self.palyer play];
}

- (void)stopPlay
{
    [self.palyer stop];
    self.palyer = nil;
}

- (void)playToEnd:(XBPCMPlayer *)player
{
    self.palyer = nil;
}

@end
