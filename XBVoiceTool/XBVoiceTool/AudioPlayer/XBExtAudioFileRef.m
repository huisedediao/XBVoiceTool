//
//  XBExtAudioFileRef.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/24.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBExtAudioFileRef.h"
#import "XBAudioTool.h"

@interface XBExtAudioFileRef ()
{
    ExtAudioFileRef _mAudioFileRef;
}
@end

@implementation XBExtAudioFileRef
- (instancetype)initWithStorePath:(NSString *)storePath inputFormat:(AudioStreamBasicDescription *)inputFormat
{
    if (self = [super init])
    {
        [self createOutFileWithStorePath:storePath inputFormat:inputFormat];
    }
    return self;
}
- (void)createOutFileWithStorePath:(NSString *)storePath inputFormat:(AudioStreamBasicDescription *)inputFormat
{
    AudioStreamBasicDescription outputDesc = *inputFormat;
    NSString *destinationFilePath = storePath;
    CFURLRef destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    CheckError(ExtAudioFileCreateWithURL(destinationURL,
                                         kAudioFileCAFType,
                                         &outputDesc,
                                         NULL,
                                         kAudioFileFlags_EraseFile,
                                         &_mAudioFileRef),"Couldn't create a file for writing");
    CFRelease(destinationURL);
    
//    AudioStreamBasicDescription tempDesc;
//    uint32_t size = sizeof(AudioStreamBasicDescription);
//    CheckError(ExtAudioFileGetProperty(_mAudioFileRef,
//                                       kExtAudioFileProperty_ClientDataFormat,
//                                       &size,
//                                       &tempDesc),
//               "cant get the DataFormat");
    
//    UInt32 codecManf = kAppleHardwareAudioCodecManufacturer;
//    CheckError(ExtAudioFileSetProperty(_mAudioFileRef, kExtAudioFileProperty_CodecManufacturer, sizeof(UInt32), &codecManf)," set CodecManufacturer failure");
//    CheckError(ExtAudioFileSetProperty(_mAudioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(outputDesc), &outputDesc),"set ClientDataFormat failure");
}
- (void)writeIoData:(AudioBufferList *)ioData inNumberFrames:(UInt32)inNumberFrames
{
    CheckError(ExtAudioFileWrite(_mAudioFileRef, inNumberFrames, ioData), "写入失败");
}

- (void)dealloc
{
    [self stopWrite];
}

- (void)stopWrite
{
    CheckError(ExtAudioFileDispose(_mAudioFileRef),"ExtAudioFileDispose failed");
}
@end
