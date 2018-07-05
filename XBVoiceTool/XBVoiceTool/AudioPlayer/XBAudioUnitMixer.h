//
//  XBAudioUnitMixer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBAudioUnitMixer : NSObject
- (instancetype)initWithPCMFilePath:(NSString *)filePath rate:(XBVoiceRate)rate channels:(XBVoiceChannel)channels bit:(XBVoiceBit)bit;
- (void)start;
- (void)stop;
@end
