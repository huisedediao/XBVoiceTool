//
//  XBPCMPlayer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@class XBPCMPlayer;
@protocol XBPCMPlayerDelegate <NSObject>
- (void)playToEnd:(XBPCMPlayer *)player;
@end

@interface XBPCMPlayer : NSObject

@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,weak) id<XBPCMPlayerDelegate>delegate;
- (instancetype)initWithPCMFilePath:(NSString *)filePath rate:(XBVoiceRate)rate channels:(XBVoiceChannel)channels bit:(XBVoiceBit)bit;
- (void)play;
- (void)stop;
@end
