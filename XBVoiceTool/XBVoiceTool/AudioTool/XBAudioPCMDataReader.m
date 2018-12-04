//
//  XBAudioPCMDataReader.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioPCMDataReader.h"

@interface XBAudioPCMDataReader ()
@property (nonatomic,assign) UInt32 readerLength;
@end

@implementation XBAudioPCMDataReader



- (int)readDataFrom:(NSData *)dataStore len:(int)len forData:(Byte *)data
{
    UInt32 currentReadLength = 0;
    if (_readerLength >= dataStore.length)
    {
        _readerLength = 0;
        return currentReadLength;
    }
    NSRange range;
    if (_readerLength+ len <= dataStore.length)
    {
        currentReadLength = len;
        range = NSMakeRange(_readerLength, currentReadLength);
        _readerLength = _readerLength + len;
    }
    else
    {
        currentReadLength = (UInt32)(dataStore.length - _readerLength);
        range = NSMakeRange(_readerLength, currentReadLength);
        _readerLength = (UInt32) dataStore.length;
    }
    
    NSData *subData = [dataStore subdataWithRange:range];
    Byte *tempByte = (Byte *)[subData bytes];
    memcpy(data,tempByte,currentReadLength);
    
    
    return currentReadLength;
}
@end
