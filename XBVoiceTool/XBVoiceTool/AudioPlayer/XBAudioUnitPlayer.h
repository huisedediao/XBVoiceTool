//
//  XBAudioUnitPlayer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/6/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

typedef void (^XBAudioUnitPlayerInputBlock)(AudioBufferList *bufferList);

@interface XBAudioUnitPlayer : NSObject
@property (nonatomic,copy) XBAudioUnitPlayerInputBlock bl_input;
- (instancetype)initWithRate:(XBVoiceRate)rate bit:(XBVoiceBit)bit channel:(XBVoiceChannel)channel;
- (void)start;
- (void)stop;
@end
