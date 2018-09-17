//
//  XBDataWriter.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

@interface XBDataWriter : NSObject
- (void)writeBytes:(void *)bytes len:(NSUInteger)len toPath:(NSString *)path;
- (void)writeData:(NSData *)data toPath:(NSString *)path;

@end
