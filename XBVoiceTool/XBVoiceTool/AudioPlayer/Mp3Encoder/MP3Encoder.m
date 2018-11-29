//
//  MP3Encoder.m
//  XBVoiceTool
//
//  Created by xxb on 2018/11/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "MP3Encoder.h"

@interface MP3Encoder ()
{
    lame_t lameClient;
}
@end

@implementation MP3Encoder

- (id)initWithSampleRate:(int)sampleRate channels:(int)channels bitRate:(int)bitRate
{
    if (self = [super init])
    {
        lameClient = lame_init();
        lame_set_in_samplerate(lameClient, sampleRate);
//        lame_set_out_samplerate(lameClient, sampleRate);
//        lame_set_mode(lameClient, 1);
        lame_set_num_channels(lameClient, 1);
        lame_set_brate(lameClient, 128);
//        lame_set_quality(lameClient, 2);
        lame_init_params(lameClient);
    }
    return self;
}

- (void)dealloc
{
    if (lameClient)
    {
        lame_close(lameClient);
    }
}
- (void)encodePCMData:(void *)pcmData len:(int)len completeBlock:(MP3EncodeCompleteBlock)completeBlock
{
    int mp3DataSize = len;
    
    unsigned char mp3Buffer[mp3DataSize];

    ///这里的len / 2，是因为我们录音数据是char *类型的，一个char占一个字节。而这里要传的数据是short *类型的，一个short占2个字节
    //不除2会有杂音
    int encodedBytes = lame_encode_buffer(lameClient, pcmData, pcmData, len / 2, mp3Buffer, mp3DataSize);
    
    if (completeBlock)
    {
        completeBlock(mp3Buffer,encodedBytes);
    }
}
@end
