//
//  XBAudioFileDataReader.h
//  XBVoiceTool
//
//  Created by xxb on 2018/7/23.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"

typedef void (^XBAudioFileDataReaderLoadFileToMemoryCompleteBlock)(XBAudioBuffer *xbBufferList);

@interface XBAudioFileDataReader : NSObject

///yes：已经把歌曲载入内存了
@property (nonatomic,assign,readonly) BOOL endLoadFileToMemory;

/**
 获取载入到内存以后的数据
 返回nil，说明没有载入完
 */
- (XBAudioBuffer *)getBufferList;
///数组长度
- (NSInteger)getBufferListLength;

///载入歌曲到内存
- (void)loadFileToMemoryWithFilePathArr:(NSArray *)filePathArr;

///载入歌曲到内存
- (void)loadFileToMemoryWithFilePathArr:(NSArray *)filePathArr completeBlock:(XBAudioFileDataReaderLoadFileToMemoryCompleteBlock)completeBlock;


@end
