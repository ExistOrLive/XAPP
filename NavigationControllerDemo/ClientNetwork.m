//
//  ClientNetwork.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/30.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "ClientNetwork.h"
#define BUFFER_SIZE 1024*256


@implementation ClientNetwork


-(instancetype)initWithIP:(NSString *) ip withPort : (NSInteger)port
{
    NSLog(@"[%@ initWithIP: withPort] : start......",[self class]);
    
    if(!ip || port == 0)
    {
        NSLog(@"[%@ initWithIP: withPort] : ip or port is nil",[self class]);
    }
    
    if([self init])
    {
        _socket = [[Socket alloc] initWithIP:ip withPort:port];
        if(!_socket)
        {
            NSLog(@"[%@ initWithIP: withPort] : Socket build or connect failed",[self class]);
            return nil;
        }
        
        NSLog(@"[%@ initWithIP: withPort] : Socket build and connect success",[self class]);
        _ip = ip;
        _port =port;
    }
    NSLog(@"[%@ initWithIP: withPort] : end......",[self class]);
    
    return self;
}


- (NSInteger)requestFile
{
    NSLog(@"[%@ %s [%d]] : start......",[self class],__func__,__LINE__);
    
    // socket == nil
    if(!self.socket)
    {
        NSLog(@"[%@ %s [%d]] : socket is nil......",[self class],__func__,__LINE__);
        
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        
        return -1;
    }
    
    //将clientNetwork保存在clientNetworkArray中，便于管理
    extern NSMutableArray * clientNetworkArray;
    [clientNetworkArray addObject:self];
    
    // 封装请求文件字符串
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    NetMessage netMessage = NetMessageConnection_Request;
    
    [dic setObject:[NSString stringWithFormat:@"%ld",netMessage] forKey:@"NetMessage"];
    
    NSString * requestStr = [Network packageMessage:dic withKey:self.key];
    
    // 请求字符串 == nil ，封装过程出错
    if(!requestStr)
    {
        NSLog(@"[%@ %s [%d]] : package request file str error......",[self class],__func__,__LINE__);
        
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        
        [self.socket close];
        
        return -1;
    }
    
    NSInteger writeLength = [self.socket writeStr:requestStr];
    // 发送请求文件字符串失败
    if(writeLength == -1)
    {
        NSLog(@"[%@ %s [%d]] :  request file str write failed......",[self class],__func__,__LINE__);
        
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        
        [self.socket close];
        
        return -1;
    }
    // 发送请求文件字符串成功
    NSLog(@"[%@ requestFile] : send request file......",[self class]);
    
    // 接受响应字符串
    NSString * resultStr = [self.socket readStr];
    // 接受请求文件字符串响应失败
    if(!resultStr)
    {
        NSLog(@"[%@ %s [%d]] :  request file response read failed......",[self class],__func__,__LINE__);
        
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        
        [self.socket close];
        
        return -1;

    }
    
    NSLog(@"[%@ requestFile] : get response: %@", [self class],resultStr);

    // 解析请求文件字符串响应
    dic = [Network parseMessgae:resultStr withKey:self.key];
    // 解析失败
    if(!dic)
    {
        NSLog(@"[%@ %s [%d]] :  parse request file str response......",[self class],__func__,__LINE__);
        
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        
        [self.socket close];
        
        return -1;
    }
    
    netMessage = [[dic objectForKey:@"NetMessage"] integerValue];
    
    NSLog(@"[%@ requestFile] : end......",[self class]);
    
    return netMessage;
    
}


/**
 @description  将服务端传来的文件信息封装为file实例，检查本地下载文件是否有过下载，并将file实例持久化到本地持久化文件中
 @prama NSDictionary * dic    文件基本信息
 @return 返回封装好的file实例
 **/
-(File *) updateDownloadArrayWithResponse:(NSDictionary *) dic
{
    
    NSLog(@"[%s [%d]]: start......",__func__,__LINE__);
    // 解析文件信息的散列表
    NSString * md5 = [dic objectForKey:@"md5"];
    NSString * fileType = [dic objectForKey:@"fileType"];
    unsigned long long fileLength = [[dic objectForKey:@"length"] integerValue];
    NSString * filePath = [NSString stringWithFormat:@"/%@.%@",md5,fileType];
    NSString * absoluteFilePath = [Tool getDownloadFilePathWithName:filePath];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
   
    // 生成file实例，并添加到downloadArray中
    int i = 0;
    File * file = nil;
    
    //检查本地downloadArray中是否存在md5值相同的file实例
    for(i = 0; i < [downloadArray count]; i++)
    {
        File * tempFile = [downloadArray objectAtIndex:i];
        if([tempFile.md5 isEqualToString:md5])
        {
            
            file = tempFile;
            
            // 如果文件已下载过，且下载成功，则直接返回
            if([tempFile isVerificated] && [fileManager fileExistsAtPath:absoluteFilePath] && fileLength == [[NSData dataWithContentsOfFile:absoluteFilePath] length])
            {
                NSMutableDictionary * responseDic = [[NSMutableDictionary alloc] init];
                
                [responseDic setValue: [NSString stringWithFormat:@"%ld",NetMessageConnection_HasDownload] forKey:@"NetMessage"];
                
                NSString * str = [Network packageMessage:responseDic withKey:self.key];
                
                [self.socket writeStr:str];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate showResult:YES withFile:file];
                });
                NSLog(@"[%@ %s [%d]] : the file has downloaded success before",[self class],__func__,__LINE__);
                
                return nil;
            }
            
            
            // 文件下载过，却没有下载完成
            if([fileManager fileExistsAtPath:absoluteFilePath] && ![tempFile isVerificated])
            {
                NSDictionary * dic = [fileManager attributesOfItemAtPath:absoluteFilePath error:nil];
                NSString * lengthStr = [dic objectForKey:NSFileSize];
                file.currentLength = [lengthStr longLongValue];
            }
            // 文件不存在
            else
            {
                file.currentLength = 0;
            }
            
            break;
            
        }
    }
    
    // 文件没有下载过
    if(i == [downloadArray count])
    {
        file = [[File alloc] init];
        [downloadArray addObject:file];
        if([fileManager fileExistsAtPath:absoluteFilePath])
        {
            [fileManager removeItemAtPath:absoluteFilePath error:nil];
        }
        file.currentLength = 0;
        
    }
    [file setMd5:md5];
    [file setLength:fileLength];
    [file setFileType:fileType];
    [file setFilePath:filePath];
    
    // 将downloadArray持久化到文件中
    NSMutableData * arrayData = [NSMutableData new];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:arrayData];
    [archiver encodeObject:downloadArray forKey:@"downloadArray"];
    [archiver finishEncoding];
    [arrayData writeToFile:[Tool getDownloadArrayPath] atomically:YES];
    
    NSLog(@"[%s [%d]]: end......",__func__,__LINE__);
    
    return file;

}




/**
 @description 接受服务端传来的文件
 **/
- (void) acceptFile
{
    NSLog(@"[%@ acceptFile] : start......",[self class]);
  
    // 1.传输前,接受文件的基本信息,并封装成file实例
    NSString * responseStr1 = [self.socket readStr];
    // 接受文件信息，错误
    if(!responseStr1)
    {
        NSLog(@"[%@ %s [%d]] :  file information read failed......",[self class],__func__,__LINE__);
        [self.socket close];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate handleError];
        });
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        return;
    }
    NSLog(@"[%@ acceptFile] : the response str is %@",[self class],responseStr1);
  
    extern NSMutableArray * downloadArray;
    // 解析文件信息字符串
    NSDictionary * dic = [Network parseMessgae:responseStr1 withKey:self.key];
    // 将文件信息封装成file
    File * file = [self updateDownloadArrayWithResponse:dic];
    if(file == nil)
    {
        [self close];
        return;
    }
    
    
    // 2. 响应 文件信息 ，将文件下载的开始地址发送给服务器
    NSMutableDictionary * responseDic = [[NSMutableDictionary alloc] init];
    [responseDic setValue: [NSString stringWithFormat:@"%ld",NetMessageConnection_OK] forKey:@"NetMessage"];
    [responseDic setValue: [NSString stringWithFormat:@"%lld",file.currentLength] forKey:@"currentLength"];
    NSString * str = [Network packageMessage:responseDic withKey:self.key];
    
    NSInteger writeLength = [self.socket writeStr:str];
    if(writeLength == -1){
        NSLog(@"[%@ %s [%d]] :  response to file information write failed......",[self class],__func__,__LINE__);
        NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate handleError];
        });
        [self close];
        return;
    }
   
    
    // 3. 开始接受文件，并更新UI层的进度条
    
    unsigned long long downloadLength = file.currentLength;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate updateProcess:downloadLength/((double)file.length)*100];
    });
    
    //文件的保存地址
    NSString * absoluteFilePath = [Tool getDownloadFilePathWithName:file.filePath];
    //临时文件地址
    NSString * absoluteTempFilePath = [absoluteFilePath stringByAppendingString:@"tmp"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:absoluteTempFilePath])
    {
        [fileManager removeItemAtPath:absoluteTempFilePath error:nil];
    }
    
    NSOutputStream * output = [[NSOutputStream alloc] initToFileAtPath:absoluteFilePath append:YES];
    [output open];
    NSOutputStream * tempOutput = [[NSOutputStream alloc] initToFileAtPath:absoluteTempFilePath append:YES];
    [tempOutput open];
    NSFileHandle * tempFileHandle = [NSFileHandle fileHandleForReadingAtPath:absoluteTempFilePath];
    
//    dispatch_queue_t serial_queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    
    //标记传输是否异常结束
     __block bool isTramissionOver = NO;
    
    //异步接受数据，保存到临时文件中
    dispatch_queue_t concurrent_queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrent_queue, ^{
        
        uint8_t * buffer = (uint8_t *) malloc(2 * BUFFER_SIZE * sizeof(int8_t));
        
        while(true)
        {
            NSInteger currentLength = [self.socket read:buffer withLength:(2*BUFFER_SIZE)];
            //网络中断的情况
            if(currentLength == 0)
            {
                [tempOutput close];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate tranmissionSuspend];
                });
                [self close];
                free(buffer);
                isTramissionOver = YES;
                NSLog(@"[%s [%d]] :  file transmission suspend with exception......",__func__,__LINE__);
                NSLog(@"[%s [%d]] : end......",__func__,__LINE__);
                return;
            }
            
            //主动关闭socket
            if(currentLength < 0)
            {
                [tempOutput close];
                free(buffer);
                NSLog(@"[%s [%d]] :  file transmission suspend with exception......",__func__,__LINE__);
                NSLog(@"[%s [%d]] : end......",__func__,__LINE__);
                return;
            }
            
            [tempOutput write:buffer maxLength:currentLength];
        }
        
    });
    
    
    // 从临时文件中读出数据，并解密保存在下载文件中
    unsigned long long offset = 0;
    uint8_t * buffer = (uint8_t *) malloc(2 * BUFFER_SIZE * sizeof(int8_t));
    while(downloadLength != file.length) {
        
        unsigned long long length = [tempFileHandle seekToEndOfFile];
        // 检查下一段数据段长度部分是否完整
        if(length < (offset + 10))
        {
            if(isTramissionOver)
                return;
            continue;
        }
        [tempFileHandle seekToFileOffset:offset];
        
        // 从长度部分中解析出长度
        NSData * segmentLengthData = [tempFileHandle readDataOfLength:10];
        NSString * str1 = [[NSString alloc] initWithData:segmentLengthData encoding:NSUTF8StringEncoding];
        NSInteger segmentLength = [str1 intValue];
        
        //检查下一段数据段数据部分是否完整
        if(length < (offset + 10 + segmentLength))
        {
            if(isTramissionOver)
                return;
            continue;
        }
        
        // 读取出加密数据
        [tempFileHandle seekToFileOffset:offset+10];
        NSData * encryptionData = [tempFileHandle readDataOfLength:segmentLength];
        
        // 解密
        NSData * decryptionData = [AES AES256ParmDecryptWithKey:self.key Decrypttext:encryptionData];
        [decryptionData getBytes:buffer length:[decryptionData length]];
        
        // 写入文件
        [output write:buffer maxLength:[decryptionData length]];
        
        // 更新游标
        offset = offset + 10 + segmentLength;
        
        // 更新进度条
        downloadLength +=[decryptionData length];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateProcess:downloadLength/((double)file.length)*100];
        });
        // 下载完成退出循环
        if(downloadLength == file.length)
        {
            break;
        }
    
    }
    
    
//    // 3. 开始接受文件，并更新UI层的进度条
//
//    unsigned long long downloadLength = file.currentLength;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.delegate updateProcess:downloadLength/((double)file.length)*100];
//    });
//    
//    NSString * absoluteFilePath = [Tool getDownloadFilePathWithName:file.filePath];
//    
//    NSOutputStream * output = [[NSOutputStream alloc] initToFileAtPath:absoluteFilePath append:YES];
//    [output open];
//    
//    uint8_t * buffer = (uint8_t *) malloc(2 * BUFFER_SIZE * sizeof(int8_t));
//    
//    while(true)
//    {
//       
//        // 接受完整的分片（ 2*BUFFER_SIZE ）
//        int length = 0;
//        NSMutableData * packageData = [[NSMutableData alloc] init];
//        while(length != 2*BUFFER_SIZE)
//        {
//            NSInteger currentLength = [self.socket read:buffer withLength:(2*BUFFER_SIZE -length)];
//            
//            //网络中断的情况
//            if(currentLength == 0)
//            {
//                [output close];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.delegate tranmissionSuspend];
//                });
//                [self close];
//                NSLog(@"[%@ %s [%d]] :  file transmission suspend with exception......",[self class],__func__,__LINE__);
//                NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
//                return;
//            }
//            
//            //主动关闭socket
//            if(currentLength < 0)
//            {
//                [output close];
//                NSLog(@"[%@ %s [%d]] :  file transmission suspend with exception......",[self class],__func__,__LINE__);
//                NSLog(@"[%@ %s [%d]] : end......",[self class],__func__,__LINE__);
//                return;
//            }
//            [packageData appendBytes:buffer length:currentLength];
//            length += currentLength;
//        }
//   
//        
//        // 从分片中解析出文件数据片密文
//        NSData * encryptionData = [Network parsePackageData:packageData];
//        
//        // 解密出明文
//        NSData * decryptionData = [AES AES256ParmDecryptWithKey:self.key Decrypttext:encryptionData];
//        [decryptionData getBytes:buffer length:[decryptionData length]];
//        
//        //写入本地下载文件
//        [output write:buffer maxLength:[decryptionData length]];
//
//        downloadLength +=[decryptionData length];
//        
//        // 更新进度条
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate updateProcess:downloadLength/((double)file.length)*100];
//        });
//         // 下载完成退出循环
//        if(downloadLength == file.length)
//            break;
//    }
//    
    NSLog(@"[%s [%d]] : file download finished ......",__func__,__LINE__);
    free(buffer);
    [output close];
    [fileManager removeItemAtPath:absoluteTempFilePath error:nil];
    
    //4. 检查文件的一致性
    [self checkConsistency:file];
    
    [self close];
    
    NSLog(@"[%s [%d]] : end......",__func__,__LINE__);
}

/**
 检查文件的一致性，即检查file对象中md5属性与filePath对应文件的md5值做比较
 @prama file 即将检查的file实例
 **/
-(void) checkConsistency:(File *) file
{
    
    NSString * absolutePath = [Tool getDownloadFilePathWithName:file.filePath];
    
    NSMutableData * arrayData = nil;
    NSKeyedArchiver * archiver = nil;
    
    if([file checkConsistency])
    {
        NSLog(@"[%s [%d]]  : download file success!!!!!!",__func__,__LINE__);
        
        [file setIsVerificated:YES];
        NSMutableData * arrayData = [NSMutableData new];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:arrayData];
        [archiver encodeObject:downloadArray forKey:@"downloadArray"];
        [archiver finishEncoding];
        [arrayData writeToFile:[Tool getDownloadArrayPath] atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate showResult:YES withFile:file];
        });
        
    }
    else
    {
        NSLog(@"[%s [%d]] : download file failed!!!!!!",__func__,__LINE__);
        
        [downloadArray removeObject:file];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:absolutePath error:nil];
        
        arrayData = [NSMutableData new];
        archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:arrayData];
        [archiver encodeObject:downloadArray forKey:@"downloadArray"];
        [archiver finishEncoding];
        [arrayData writeToFile:[Tool getDownloadArrayPath] atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate showResult:NO withFile:nil];
        });
        
    }
    

}

/**
 关闭客户端下载
 **/
- (bool) close
{
    NSLog(@"[%s [%d]] : close!!!!!!",__func__,__LINE__);
    if(self.socket)
    {
        if([self.socket close]){
            extern NSMutableArray * clientNetworkArray;
            [clientNetworkArray removeObject:self];
            _ip = nil;
            _port = 0;
            return YES;
        }
        else
            return NO;
    }
    return YES;
}



@end
