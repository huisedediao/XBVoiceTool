//
//  XBAudioDataReader.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioDataReader.h"

@interface XBAudioDataReader ()
@property (nonatomic,assign) UInt32 readerLength;
@end

@implementation XBAudioDataReader



- (int)readDataFrom:(NSData *)dataStore len:(int)len forData:(Byte *)data
{
    UInt32 currentReadLength = 0;
    if (_readerLength >= dataStore.length)
    {
        _readerLength = 0;
        return currentReadLength;
    }
    if (_readerLength+ len <= dataStore.length)
    {
        _readerLength = _readerLength + len;
        currentReadLength = len;
    }
    else
    {
        currentReadLength = (UInt32)(dataStore.length - _readerLength);
        _readerLength = (UInt32) dataStore.length;
    }
    
    NSData *subData = [dataStore subdataWithRange:NSMakeRange(_readerLength, currentReadLength)];
    Byte *tempByte = (Byte *)[subData bytes];
    memcpy(data,tempByte,currentReadLength);
    
    
    return currentReadLength;
}
@end
