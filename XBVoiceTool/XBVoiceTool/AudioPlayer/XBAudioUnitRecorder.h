//
//  XBAudioUnitRecorder.h
//  XBVoiceTool
//
//  Created by xxb on 2018/6/28.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

typedef void (^XBAudioUnitRecorderOnputBlock)(AudioBufferList *bufferList);

@interface XBAudioUnitRecorder : NSObject
@property (nonatomic,copy) XBAudioUnitRecorderOnputBlock bl_outputBlock;
- (instancetype)initWithRate:(XBVoiceRate)rate bit:(XBVoiceBit)bit channel:(XBVoiceChannel)channel;
- (void)start;
- (void)stop;
@end
