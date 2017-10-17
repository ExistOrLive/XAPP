

//
//  MD5.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "MD5.h"

@implementation MD5

+ (NSString *)md5EncodeFromData:(NSData *)data {
    if (!data) {
        return nil;
    }
    //需要MD5变量并且初始化
    CC_MD5_CTX  md5;
    CC_MD5_Init(&md5);
    //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    //声明一个无符号的字符数组，用来盛放转换好的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //将数据放入result数组
    CC_MD5_Final(result, &md5);
    //将result中的字符拼接为OC语言中的字符串，以便我们使用。
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X",result[i]];
    }
   // NSLog(@"resultString=========%@",resultString);
    return resultString;
}

+ (NSString *)md5EncodeFromFileHandle:(NSFileHandle *)fileHandle
{
    if(!fileHandle)
        return nil;
    
    unsigned long long  length = [fileHandle seekToEndOfFile];
    
    [fileHandle seekToFileOffset:0];
    
    int num = length / (1024*1024*20);
    
    int lastLength = length % (1024*1024*20);
    
    unsigned long long location = 0;
    
    NSMutableArray * md5Array = [[NSMutableArray alloc] init];
    
    NSData * data = nil;
    
    NSString * md5 = nil;
    
    for(int i = 0; i <num; i++)
    {
        data = [fileHandle readDataOfLength:(1024*1024)];
        md5 = [MD5 md5EncodeFromData:data];
        NSLog(@"num : %d  md5 : %@",i,md5);
        [md5Array addObject:md5];
        location +=1024*1024*20;
        [fileHandle seekToFileOffset:location];
    }
    
    if(lastLength != 0)
    {
        data = [fileHandle readDataToEndOfFile];
        md5 = [MD5 md5EncodeFromData:data];
        [md5Array addObject:md5];
    }
    
    NSMutableString * allMD5 = [[NSMutableString alloc] init];
    for(int i = 0 ;i < [md5Array count]; i++)
    {
        [allMD5 appendString:[md5Array objectAtIndex:i]];
    }
    
    NSData * allData  = [allMD5 dataUsingEncoding:NSUTF8StringEncoding];
    NSString * result = [MD5 md5EncodeFromData:allData];
    NSLog(@"md5 == %@",result);
    
    return result;
}
@end
