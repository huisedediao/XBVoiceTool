//
//  XBAudioDataBuffer.m
//  smanos
//
//  Created by xxb on 2018/9/7.
//  Copyright © 2018年 sven. All rights reserved.
//

#import "XBAudioDataBuffer.h"

@interface XBAudioDataBuffer ()
{
    NSLock *_lock;//锁
    char *_dataBuffer;//缓冲池
    int _availableLen;//可用数据的长度
    int _buf_size;//记录XBAudioDataBuffer的最大长度
    int _w_pos;//写入数据的偏移地址
    int _r_pos;//读取数据的偏移地址
}
@end

@implementation XBAudioDataBuffer

/**
 bufferSize : 缓冲池最大长度
 */
- (instancetype)initWithBufferSize:(int)bufferSize
{
    if (self = [super init])
    {
        _lock = [NSLock new];
        _buf_size = bufferSize;
        
        _dataBuffer = (char *)malloc(bufferSize * sizeof(char));
    }
    return self;
}

/** 写入数据
 data : 要写入到缓冲池的数据
 len  : 要写入到数据的长度
 */
- (int)writeData:(void *)data len:(int)len
{
    if(len+_availableLen > _buf_size)
    {
        printf("Data len is more than buffer size!\n");
        return 0;
    }
    
    [_lock lock];

    if((_w_pos+len) <= _buf_size)
    {
        memcpy(_dataBuffer+_w_pos,data,len);
        _w_pos += len;
    }
    else
    {
        int len1 = _buf_size - _w_pos;
        memcpy(_dataBuffer+_w_pos,data,len1);
        memcpy(_dataBuffer,data+len1,len-len1);
        _w_pos = len-len1;
    }
    _availableLen += len;
    
    [_lock unlock];
    
    return len;
}

/** 读取数据
 len  : 要读取多长的数据
 data : 读取的数据提供给谁
 */
- (int)readLen:(int)len toData:(void *)data
{
    if(_availableLen < len)
    {
        return 0;
    }
    [_lock lock];
    
    if((_r_pos+len) <= _buf_size)
    {
        memcpy(data,_dataBuffer+_r_pos,len);
        _r_pos += len;
    }
    else
    {
        int len1 = _buf_size - _r_pos;
        memcpy(data,_dataBuffer+_r_pos,len1);
        memcpy(data+len1,_dataBuffer,len-len1);
        _r_pos = len-len1;
    }
    _availableLen -= len;
    
    [_lock unlock];
    
    return len;
}

- (void)dealloc
{
    [self free];
}

- (void)free
{
    free(_dataBuffer);
}

- (void)clearData
{
    _r_pos = 0;
    _w_pos = 0;
    _availableLen = 0;
}

@end
