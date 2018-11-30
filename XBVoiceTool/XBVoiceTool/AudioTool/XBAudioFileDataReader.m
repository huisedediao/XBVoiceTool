//
//  XBAudioFileDataReader.m
//  XBVoiceTool
//
//  Created by xxb on 2018/7/23.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioFileDataReader.h"
#import "XBAudioTool.h"

@interface XBAudioFileDataReader ()
{
    XBAudioBuffer *_bufferList;
    NSInteger _bufferListLength;
}
@end

@implementation XBAudioFileDataReader

- (XBAudioBuffer *)getBufferList
{
    if (_endLoadFileToMemory)
    {
        return _bufferList;
    }
    return nil;
}

- (NSInteger)getBufferListLength
{
    return _bufferListLength;
}

///载入歌曲到内存
- (void)loadFileToMemoryWithFilePathArr:(NSArray *)filePathArr
{
    [self loadFileToMemoryWithFilePathArr:filePathArr completeBlock:nil];
}

- (void)loadFileToMemoryWithFilePathArr:(NSArray *)filePathArr completeBlock:(XBAudioFileDataReaderLoadFileToMemoryCompleteBlock)completeBlock
{
    _bufferListLength = filePathArr.count;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        XBAudioBuffer *bufferList = (XBAudioBuffer *)malloc(sizeof(XBAudioBuffer) * filePathArr.count);
//        XBAudioBufferList bufferList = (XBAudioBufferList)malloc(sizeof(XBAudioBuffer) * filePathArr.count);
        for (NSString *filePath in filePathArr)
        {
            NSInteger i = [filePathArr indexOfObject:filePath];

            __block float rateRate = 1;
            __block UInt32 channel = 1;
            [XBAudioTool getAudioPropertyWithFilepath:filePath completeBlock:^(AudioFileID audioFileID, AudioStreamBasicDescription audioFileFormat, UInt64 packetNums, UInt64 maxFramesPerPacket, UInt64 fileLengthFrames) {
                rateRate = kSmapleRate * 1.0 / audioFileFormat.mSampleRate;
                if (audioFileFormat.mChannelsPerFrame == 2)
                {
                    channel = 2;
                }
            } errorBlock:^(NSError *error) {
            }];

            //NO表示如果是双声道数据，两个声道的数据分别在不同的数组里
            AVAudioFormat *clientFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                                           sampleRate:kSmapleRate
                                                                             channels:channel
                                                                          interleaved:NO];

            UInt32 size = sizeof(AudioStreamBasicDescription);


            ExtAudioFileRef fp;
            NSURL *url = [NSURL fileURLWithPath:filePath];
            CheckError(ExtAudioFileOpenURL((__bridge CFURLRef _Nonnull)(url), &fp), "cant open the file");
            //设置从文件中读出的音频格式
            CheckError(ExtAudioFileSetProperty(fp, kExtAudioFileProperty_ClientDataFormat,
                                               size, clientFormat.streamDescription),
                       "cant set the file output format");
            //获取总帧数，乘以rateRate，是为了获取正确的帧数，因为这里设置输出的格式，rate为kSmapleRate
            UInt64 numFrames = 0;
            size = sizeof(numFrames);
            CheckError(ExtAudioFileGetProperty(fp, kExtAudioFileProperty_FileLengthFrames,
                                               &size, &numFrames),
                       "cant get the fileLengthFrames");
            numFrames = numFrames * rateRate;

            //设置bufferList
            bufferList[i].totalFrames = numFrames;
            bufferList[i].asbd = *(clientFormat.streamDescription);
            bufferList[i].channelCount = channel;
            bufferList[i].startFrame = 0;
            bufferList[i].leftData = (Float32 *)malloc(numFrames * sizeof(Float32));
            if (channel == 2)
            {
                bufferList[i].rightData = (Float32 *)malloc(numFrames * sizeof(Float32));
            }

            //把数据读取到bufferList的leftData和rightData中
            AudioBufferList *bufList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + (channel - 1) * sizeof(AudioBuffer));
            AudioBuffer emptyBuffer = {0};
            for (int j = 0; j < channel; j++) {
                bufList->mBuffers[j] = emptyBuffer;
            }
            bufList->mNumberBuffers = channel;

            bufList->mBuffers[0].mNumberChannels = 1;
            bufList->mBuffers[0].mData = bufferList[i].leftData;
            bufList->mBuffers[0].mDataByteSize = (UInt32)numFrames*sizeof(Float32);

            if (2 == channel) {
                bufList->mBuffers[1].mNumberChannels = 1;
                bufList->mBuffers[1].mDataByteSize = (UInt32)numFrames*sizeof(Float32);
                bufList->mBuffers[1].mData = bufferList[i].rightData;
            }

            UInt32 numberOfPacketsToRead = (UInt32) numFrames;
            CheckError(ExtAudioFileRead(fp,
                                        &numberOfPacketsToRead,
                                        bufList),
                       "cant read the audio file");
            free(bufList);
            ExtAudioFileDispose(fp);
        }

        _bufferList = bufferList;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock)
            {
                completeBlock(bufferList);
            }
            _endLoadFileToMemory = YES;
        });
    });
}

@end
