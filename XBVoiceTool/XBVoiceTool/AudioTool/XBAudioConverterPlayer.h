//
//  XBAudioConverterPlayer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBAudioConverterPlayer : NSObject
@property (nonatomic,assign) BOOL isPlaying;
- (instancetype)initWithFilePath:(NSString *)filePath;
- (void)play;
- (void)stop;
@end
