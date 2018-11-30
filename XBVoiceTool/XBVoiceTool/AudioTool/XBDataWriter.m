//
//  XBDataWriter.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBDataWriter.h"

@interface XBDataWriter ()
@property (nonatomic,strong) NSLock *lock;
@end

@implementation XBDataWriter


- (void)writeBytes:(void *)bytes len:(NSUInteger)len toPath:(NSString *)path
{
    NSData *data = [NSData dataWithBytes:bytes length:len];
    [self writeData:data toPath:path];
    
    //    NSString *savePath = path;
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath] == false)
    //    {
    //        [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    //    }
    
//    static FILE *fp=NULL;
//    
//    if(fp==NULL || access( [path UTF8String], F_OK )==-1){
//        
//        fp = fopen([path UTF8String], "ab+" );
//        
//        if(fp==NULL){
//            
//            printf("can't open file!");
//            
//            fp=NULL;
//            
//            return;
//            
//        }
//        
//    }
//    
//    if(fp!=NULL){
//        
//        fwrite(bytes , 1 , len , fp );
//        
//        printf("write to file %zd bytes",bytes);
//        
//    }
}

- (void)writeData:(NSData *)data toPath:(NSString *)path
{
    [self.lock lock];
    
    NSString *savePath = path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath] == false)
    {
        [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    }
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:savePath];
    [handle seekToEndOfFile];
    [handle writeData:data];
    
    [self.lock unlock];
}

- (NSLock *)lock
{
    if (_lock == nil)
    {
        _lock = [NSLock new];
    }
    return _lock;
}
@end

