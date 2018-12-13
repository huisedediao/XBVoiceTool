//
//  XBAudioDataBuffer.h
//  smanos
//
//  Created by xxb on 2018/9/7.
//  Copyright © 2018年 sven. All rights reserved.
//  缓冲池，用于接受网络数据

#import <Foundation/Foundation.h>

@interface XBAudioDataBuffer : NSObject

/**
 bufferSize : 缓冲池最大长度
 */
- (instancetype)initWithBufferSize:(int)bufferSize;

/** 写入数据
 data : 要写入到缓冲池的数据
 len  : 要写入到数据的长度
 */
- (int)writeData:(void *)data len:(int)len;

/** 读取数据
 len  : 要读取多长的数据
 data : 读取的数据提供给谁
 */
- (int)readLen:(int)len toData:(void *)data;

- (void)clearData;

/** 读取数据
 获取当前已经缓冲好的长度
 */
- (int)availableLen;

@end
