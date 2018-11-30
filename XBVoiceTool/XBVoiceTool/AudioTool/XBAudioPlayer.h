//
//  XBAudioPlayer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/10.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBAudioPlayer : NSObject
- (instancetype)initWithFilePath:(NSString *)filePath;
- (void)start;
- (void)stop;
- (float)getProgress;
@end
