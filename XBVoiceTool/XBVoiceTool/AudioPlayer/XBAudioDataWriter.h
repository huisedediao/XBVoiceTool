//
//  XBAudioDataWriter.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBAudioDataWriter : NSObject
- (void)writeBytes:(Byte *)bytes len:(NSUInteger)len toPath:(NSString *)path;
- (void)writeData:(NSData *)data toPath:(NSString *)path;
@end
