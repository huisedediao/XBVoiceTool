//
//  XBAudioUnitMixerTest.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBAudioUnitMixerTest : NSObject
- (instancetype)initWithPCMFilePath:(NSString *)filePath rate:(XBAudioRate)rate channels:(XBAudioChannel)channels bit:(XBAudioBit)bit;
- (void)start;
- (void)stop;
@end
