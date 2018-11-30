//
//  XBAudioUnitMixer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/18.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBAudioUnitMixer : NSObject

@property (nonatomic,assign,readonly) BOOL isPlaying;

- (instancetype)initWithFilePathArr:(NSArray *)filePathArr;
- (void)start;
- (void)pause;
- (void)enableInput:(BOOL)enable forBus:(int)busIndex;
- (void)setInputVolumeValue:(CGFloat)value forBus:(int)busIndex;
- (void)setOutputVolumeValue:(AudioUnitParameterValue)value;
@end
