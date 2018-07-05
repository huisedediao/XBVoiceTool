//
//  XBAudioFormatConversion.m
//  XBVoiceTool
//
//  Created by xxb on 2018/6/27.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioFormatConversion.h"
#import "lame.h"
#import <UIKit/UIKit.h>

@implementation XBAudioFormatConversion

///PCM转MP3
+ (NSString *)audio_PCMToMP3:(NSString *)pcmFilePath rate:(XBVoiceRate)rate
{
    NSString *mp3FilePath = [NSString stringWithFormat:@"%@XB_PCMToMP3.mp3",NSTemporaryDirectory()];
    
    NSString *_recordFilePath = pcmFilePath;
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([_recordFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
        
        
        
        const int PCM_SIZE = 8192;//8192
        
        const int MP3_SIZE = 8192;//8192
        
        short int pcm_buffer[PCM_SIZE*2];
        
        unsigned char mp3_buffer[MP3_SIZE];
        
        
        
        lame_t lame = lame_init();
        
        //        lame_set_in_samplerate(lame, 7500.0);//采样播音速度，值越大播报速度越快，反之。
        lame_set_in_samplerate(lame, rate);//采样播音速度，值越大播报速度越快，反之。
        
        lame_set_VBR(lame, vbr_default);
        
        lame_init_params(lame);
        
        do {
            
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                
            {
                
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                
            }
            
            else
                
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            
            
            fwrite(mp3_buffer, write, 1, mp3);
            
            
            
        } while (read != 0);
        
        
        
        lame_close(lame);
        
        fclose(mp3);
        
        fclose(pcm);
        
    }
    
    @catch (NSException *exception) {
        
        NSLog(@"%@",[exception description]);
        
    }
    
    @finally {
        
        //do some
        NSLog(@"MP3生成成功: %@",mp3FilePath);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mp3转化成功！" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
    }
    
    return mp3FilePath;
}


///PCM转WAV
+ (NSString *)audio_PCMToWAV:(NSString *)pcmFilePath rate:(XBVoiceRate)rate channels:(int)channels
{
    NSString *wavPath = [NSString stringWithFormat:@"%@XB_PCMToWAV.wav",NSTemporaryDirectory()];
    char *pcmPath_c = (char *)[pcmFilePath UTF8String];
    char *wavPath_c = (char *)[wavPath UTF8String];
    convertPcm2Wav(pcmPath_c, wavPath_c, channels, rate);
    return wavPath;
}


// pcm 转wav

//wav头的结构如下所示：

typedef  struct  {
    
    char        fccID[4];
    
    int32_t      dwSize;
    
    char        fccType[4];
    
} HEADER;

typedef  struct  {
    
    char        fccID[4];
    
    int32_t      dwSize;
    
    int16_t      wFormatTag;
    
    int16_t      wChannels;
    
    int32_t      dwSamplesPerSec;
    
    int32_t      dwAvgBytesPerSec;
    
    int16_t      wBlockAlign;
    
    int16_t      uiBitsPerSample;
    
}FMT;

typedef  struct  {
    
    char        fccID[4];
    
    int32_t      dwSize;
    
}DATA;

/*
 int convertPcm2Wav(char *src_file, char *dst_file, int channels, int sample_rate)
 请问这个方法怎么用?参数都是什么意思啊
 
 赞  回复
 code书童： @不吃鸡爪 pcm文件路径，wav文件路径，channels为通道数，手机设备一般是单身道，传1即可，sample_rate为pcm文件的采样率，有44100，16000，8000，具体传什么看你录音时候设置的采样率。
 */

int convertPcm2Wav(char *src_file, char *dst_file, int channels, int sample_rate)

{
    int bits = 16;
    
    //以下是为了建立.wav头而准备的变量
    
    HEADER  pcmHEADER;
    
    FMT  pcmFMT;
    
    DATA  pcmDATA;
    
    unsigned  short  m_pcmData;
    
    FILE  *fp,*fpCpy;
    
    if((fp=fopen(src_file,  "rb"))  ==  NULL) //读取文件
        
    {
        
        printf("open pcm file %s error\n", src_file);
        
        return -1;
        
    }
    
    if((fpCpy=fopen(dst_file,  "wb+"))  ==  NULL) //为转换建立一个新文件
        
    {
        
        printf("create wav file error\n");
        
        return -1;
        
    }
    
    //以下是创建wav头的HEADER;但.dwsize未定，因为不知道Data的长度。
    
    strncpy(pcmHEADER.fccID,"RIFF",4);
    
    strncpy(pcmHEADER.fccType,"WAVE",4);
    
    fseek(fpCpy,sizeof(HEADER),1); //跳过HEADER的长度，以便下面继续写入wav文件的数据;
    
    //以上是创建wav头的HEADER;
    
    if(ferror(fpCpy))
        
    {
        
        printf("error\n");
        
    }
    
    //以下是创建wav头的FMT;
    
    pcmFMT.dwSamplesPerSec=sample_rate;
    
    pcmFMT.dwAvgBytesPerSec=pcmFMT.dwSamplesPerSec*sizeof(m_pcmData);
    
    pcmFMT.uiBitsPerSample=bits;
    
    strncpy(pcmFMT.fccID,"fmt  ", 4);
    
    pcmFMT.dwSize=16;
    
    pcmFMT.wBlockAlign=2;
    
    pcmFMT.wChannels=channels;
    
    pcmFMT.wFormatTag=1;
    
    //以上是创建wav头的FMT;
    
    fwrite(&pcmFMT,sizeof(FMT),1,fpCpy); //将FMT写入.wav文件;
    
    //以下是创建wav头的DATA;  但由于DATA.dwsize未知所以不能写入.wav文件
    
    strncpy(pcmDATA.fccID,"data", 4);
    
    pcmDATA.dwSize=0; //给pcmDATA.dwsize  0以便于下面给它赋值
    
    fseek(fpCpy,sizeof(DATA),1); //跳过DATA的长度，以便以后再写入wav头的DATA;
    
    fread(&m_pcmData,sizeof(int16_t),1,fp); //从.pcm中读入数据
    
    while(!feof(fp)) //在.pcm文件结束前将他的数据转化并赋给.wav;
        
    {
        
        pcmDATA.dwSize+=2; //计算数据的长度；每读入一个数据，长度就加一；
        
        fwrite(&m_pcmData,sizeof(int16_t),1,fpCpy); //将数据写入.wav文件;
        
        fread(&m_pcmData,sizeof(int16_t),1,fp); //从.pcm中读入数据
        
    }
    
    fclose(fp); //关闭文件
    
    pcmHEADER.dwSize = 0;  //根据pcmDATA.dwsize得出pcmHEADER.dwsize的值
    
    rewind(fpCpy); //将fpCpy变为.wav的头，以便于写入HEADER和DATA;
    
    fwrite(&pcmHEADER,sizeof(HEADER),1,fpCpy); //写入HEADER
    
    fseek(fpCpy,sizeof(FMT),1); //跳过FMT,因为FMT已经写入
    
    fwrite(&pcmDATA,sizeof(DATA),1,fpCpy);  //写入DATA;
    
    fclose(fpCpy);  //关闭文件
    
    return 0;
    
}
@end
