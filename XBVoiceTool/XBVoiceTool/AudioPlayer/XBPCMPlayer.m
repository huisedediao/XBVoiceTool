//
//  XBPCMPlayer.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBPCMPlayer.h"
#import "XBAudioUnitPlayer.h"
#import "XBAudioDataReader.h"

@interface XBPCMPlayer ()
@property (nonatomic,strong) NSData *dataStore;
@property (nonatomic,strong) XBAudioUnitPlayer *player;
@property (nonatomic,strong) XBAudioDataReader *reader;
@end

@implementation XBPCMPlayer

- (instancetype)initWithPCMFilePath:(NSString *)filePath rate:(XBVoiceRate)rate channels:(XBVoiceChannel)channels bit:(XBVoiceBit)bit
{
    if (self = [super init])
    {
        self.filePath = filePath;
        self.player = [[XBAudioUnitPlayer alloc] initWithRate:rate bit:bit channel:channels];
        self.reader = [XBAudioDataReader new];
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"XBPCMPlayer销毁");
    [self.player stop];
    self.player = nil;
}
- (void)play
{
    if (self.player.bl_input == nil)
    {
        typeof(self) __weak weakSelf = self;
        self.player.bl_input = ^(AudioBufferList *bufferList) {

            AudioBuffer buffer = bufferList->mBuffers[0];
            int len = buffer.mDataByteSize;
            int readLen = [weakSelf.reader readDataFrom:weakSelf.dataStore len:len forData:buffer.mData];
            buffer.mDataByteSize = readLen;
            if (readLen == 0)
            {
                [weakSelf stop];
            }
        };
    }
    [self.player start];
    self.isPlaying = YES;
}
- (void)stop
{
    self.player.bl_input = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPreferredIOBufferDuration*0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player stop];
        self.isPlaying = NO;
    });
}


#pragma mark - 方法重写
- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    self.dataStore = [NSData dataWithContentsOfFile:filePath];
}


@end
