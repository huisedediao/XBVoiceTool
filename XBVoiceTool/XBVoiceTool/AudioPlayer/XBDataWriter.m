//
//  XBDataWriter.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/5.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBDataWriter.h"

@implementation XBDataWriter

- (void)writeBytes:(Byte *)bytes len:(NSUInteger)len toPath:(NSString *)path
{
    static FILE *fp=NULL;
    
    if(fp==NULL || access( [path UTF8String], F_OK )==-1){
        
        fp = fopen([path UTF8String], "ab+" );
        
        if(fp==NULL){
            
            printf("can't open file!");
            
            fp=NULL;
            
            return;
            
        }
        
    }
    
    if(fp!=NULL){
        
        fwrite(bytes , 1 , len , fp );
        
        printf("write to file %zd bytes",bytes);
        
    }
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
