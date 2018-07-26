//
//  ExtAudioFileMixer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/25.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExtAudioFileMixer : NSObject

+ (OSStatus)mixAudio:(NSString *)audioPath1
            andAudio:(NSString *)audioPath2
              toFile:(NSString *)outputPath
  preferedSampleRate:(float)sampleRate;

@end
