
//
//  TransmissionServer.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "TransmissionServer.h"
#define BUFFER_SIZE 1024*256

@implementation TransmissionServer


/**
 初始化文件传输服务器
 @prama file 即将传输的文件
 @prama connectionSocket socket连接
 
 @return TramissionServer 实例
 **/
- (instancetype) initWithFile: (File *) file withConnectionSocket:(Socket *)  connectionSocket
{
    NSLog(@"[%@ initWithFile:withConnectionSocket : start......]",[self class]);
   
    if(self = [super init])
    {
        _file = file;
        
        if(_file == nil)
        {
            NSLog(@"[%@ initWithFile:withConnectionSocket] : the file  is nil !!!!!!",[self class]);
            return nil;
        }
        
        _connectionSocket = connectionSocket;
        
        if(_connectionSocket == nil)
        {
            NSLog(@"[%@ initWithFile:withConnectionSocket] : the connectionSocket is nil !!!!!!",[self class]);
            return nil;
        }
        
    }
    
    
    NSLog(@"[%@ initWithFile:withConnectionSocket : end......]",[self class]);
    
    return self;
}

/**
 * @description 传输文件的主要代码
 **/
- (void) transmission
{
    NSLog(@"[%s [%d]] start......",__func__,__LINE__);
    
    unsigned long long length = self.file.length;
    NSFileHandle * fileHandle = self.file.fileHandle;
    [fileHandle seekToFileOffset:0];
    
    //1. 文件传输前的信息交互，通知客户端文件的基本信息，服务端获取文件传输的起点指针
   unsigned long long location = [self beforeTramission];

    //2.如果信息交互没有出错，则开始传输文件数据
    if(location != -1){
        
      //  uint8_t buffer[BUFFER_SIZE];
        
        uint8_t * buffer = (uint8_t *)malloc(2*BUFFER_SIZE*sizeof(uint8_t));
        
        while(location < length)
        {
            //2.1 移动文件游标至发送处
            [fileHandle seekToFileOffset:location];
            
            //2.2 获取本次循环传递的长度和数据
            NSInteger currentLength = (location+BUFFER_SIZE) > length ? (length-location):BUFFER_SIZE;
            NSData * data = [fileHandle readDataOfLength:currentLength];
            
            
            //2.3 加密数据
            NSData * encrytionData = [AES AES256ParmEncryptWithKey:self.key Encrypttext:data];
            
            
            // 2.4 封装数据
            NSData * packageData = [Network packageFileData:encrytionData];
            [packageData getBytes:buffer length:[packageData length]];

            
            
            NSInteger writeLength = [self.connectionSocket write:buffer withLength:[packageData length]];
          
            // 文件传输过程中出错
            if(writeLength == -1)
            {
                NSLog(@"[%s [%d]] : file tramission write failed",__func__,__LINE__);
    
               //[self.connectionSocket close];
                
                NSLog(@"[%s [%d]] : end......",__func__,__LINE__);
                
                return;
            }
            
        
            location += currentLength;
        }
        
        free(buffer);
      
        NSLog(@"[%s [%d]] : tranmission end!!!!!",__func__,__LINE__);
    }
    
    NSLog(@"[%s [%d]]: end......",__func__,__LINE__);


}


/**
 * @description 文件正式传输前，交互文件的基本信息,服务端传递md5，length ，type等参数，客户端传递文件的起点指针location
 * @return 返回文件的起点指针， 如果为-1，则出现异常
 **/
- (unsigned long long) beforeTramission
{
    
    
    // 文件正式传输前，交互文件的基本信息 （md5，length ，type）
    NSString * md5 = self.file.md5;
    NSString * fileType = self.file.fileType;
    unsigned long long length = self.file.length;
    
    // 1. 封装文件基本信息字符串
    NSMutableDictionary * dic = [NSMutableDictionary new];
    [dic setObject:md5 forKey:@"md5"];
    [dic setObject:fileType forKey:@"fileType"];
    [dic setObject:[NSString stringWithFormat:@"%lld",length] forKey:@"length"];
    NSString * messageBeforeTransmission = [Network packageMessage:dic withKey:self.key];
    
    // 字符串封装出错
    if(!messageBeforeTransmission)
    {
        NSLog(@"[%@ transmission] packageMessage failed!!!!!!",[self class]);
        
        [self.connectionSocket close];
        
        NSLog(@"[%@ transmission] end......",[self class]);
        
        return -1;
    }
    
    
    NSInteger writeLength = [self.connectionSocket writeStr:messageBeforeTransmission];
    
    // 文件信息交互出现错误，写入出错
    if(writeLength == -1)
    {
        NSLog(@"[%@  %s [%d]] : messageBeforeTransmission write failed ",[self class],__func__,__LINE__);
        
        [self.connectionSocket close];
        
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        
        return -1;
    }
    
    NSLog(@"[%@ transmission]: send messageBeforeTransmission!!!!!!" ,[self class]);
    
    // 2. 接受客户端响应，包含信息是否已下载 ，开始指针 ，
    NSString * str = [self.connectionSocket readStr];
    
    // str == nil 接受响应字符串失败
    if(!str){
        
        NSLog(@"[%@  %s [%d]] : messageBeforeTransmission read failed",[self class],__func__,__LINE__);
        
        [self.connectionSocket close];
        
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        
        return -1;
    }
    
    NSLog(@"[%@ transmission] the response str = %@",[self class],str);
    dic = (NSMutableDictionary *)[Network parseMessgae:str withKey:self.key] ;
    NetMessage netMessage = [[dic objectForKey:@"NetMessage"] intValue];
    
    if(netMessage == NetMessageConnection_OK){
        NSString * lengthStr = [dic objectForKey:@"currentLength"];
        long long  location = [lengthStr longLongValue];
        return location;
    }
    else
    {
        return -1;
    }
    
    
    
}



@end
