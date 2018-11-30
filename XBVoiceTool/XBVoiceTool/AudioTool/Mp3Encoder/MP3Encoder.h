//
//  MP3Encoder.h
//  XBVoiceTool
//
//  Created by xxb on 2018/11/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "lame.h"

///编码后的数据再回调里提供给外部
typedef void (^MP3EncodeCompleteBlock)(unsigned char * encodedData, int len);

@interface MP3Encoder : NSObject
- (id)initWithSampleRate:(int)sampleRate channels:(int)channels bitRate:(int)bitRate;
- (void)encodePCMData:(void *)pcmData len:(int)len completeBlock:(MP3EncodeCompleteBlock)completeBlock;
@end
