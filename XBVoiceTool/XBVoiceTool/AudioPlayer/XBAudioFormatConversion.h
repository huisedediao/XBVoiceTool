//
//  XBAudioFormatConversion.h
//  XBVoiceTool
//
//  Created by xxb on 2018/6/27.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBAudioFormatConversion : NSObject
/*
 PCM转MP3
 只能转双声道数据，单声道会变快
 */
+ (NSString *)audio_PCMToMP3:(NSString *)pcmFilePath rate:(XBVoiceRate)rate;
///PCM转WAV
+ (NSString *)audio_PCMToWAV:(NSString *)pcmFilePath rate:(XBVoiceRate)rate channels:(int)channels;
@end
