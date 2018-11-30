//
//  XBAudioPCMDataReader.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBAudioPCMDataReader : NSObject
///从已有的数据中读取数据
- (int)readDataFrom:(NSData *)dataStore len:(int)len forData:(Byte *)data;
@end
