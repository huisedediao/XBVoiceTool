//
//  XBAudioDataWriter.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioDataWriter.h"

@implementation XBAudioDataWriter

- (void)writeBytes:(Byte *)bytes len:(NSUInteger)len toPath:(NSString *)path
{
    NSData *data = [NSData dataWithBytes:bytes length:len];
    [self writeData:data toPath:path];
}

- (void)writeData:(NSData *)data toPath:(NSString *)path
{
    NSString *savePath = path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath] == false)
    {
        [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    }
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:savePath];
    [handle seekToEndOfFile];
    [handle writeData:data];
}
@end
