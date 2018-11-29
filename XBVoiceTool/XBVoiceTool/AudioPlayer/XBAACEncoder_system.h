//
//  XBAACEncoder_system.h
//  XBVoiceTool
//
//  Created by xxb on 2018/11/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

///编码后的数据再回调里提供给外部
typedef void (^AACEncodeCompleteBlock)(NSData * encodedData, NSError* error);

@interface XBAACEncoder_system : NSObject

- (id)initWithInputAudioStreamDesc:(AudioStreamBasicDescription)inputAudioStreamDesc;

/**
 编码pcm数据
 */
- (void)encodePCMData:(void *)pcmData len:(int)len completionBlock:(AACEncodeCompleteBlock)completionBlock;

/**
 编码CMSampleBufferRef数据
 */
- (void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer completionBlock:(AACEncodeCompleteBlock)completionBlock;

@end
