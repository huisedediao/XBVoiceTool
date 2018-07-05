//
//  XBAudioDataReader.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/2.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBAudioDataReader : NSObject
- (int)readDataFrom:(NSData *)dataStore len:(int)len forData:(Byte *)data;
@end
