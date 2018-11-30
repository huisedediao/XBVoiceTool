//
//  XBExtAudioFileRef.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/24.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBExtAudioFileRef : NSObject
/**

 storePath：存储路径
 inputFormat : The format of the audio data to be written to the file.
 */
- (instancetype)initWithStorePath:(NSString *)storePath inputFormat:(AudioStreamBasicDescription *)inputFormat;
- (void)writeIoData:(AudioBufferList *)ioData inNumberFrames:(UInt32)inNumberFrames;
- (void)stopWrite;
@end
