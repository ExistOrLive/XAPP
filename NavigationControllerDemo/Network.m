//
//  Network.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/31.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "Network.h"

#define BUFFER_SIZE 1024*256

@implementation Network

/**
 获取本机的IP地址
 @param preferIPv4 是否为IPv4地址
 @return   返回IP地址字符串
 **/

+ (NSString *) getIPAddress: (BOOL) preferIPv4
{
   // NSLog(@"[%@ getIPAddress start......]",self.class);
    
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
   // NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    
   // NSLog(@"[%@ getIPAddress end......]",self.class);
    
    return address ? address : @"0.0.0.0";
}

/**
 获取本机所有的相关IP信息
 @return 返回本机IP信息的散列表
 **/

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs * interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface = interfaces; interface; interface = interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}



+ (NSDictionary *) parseMessgae : (NSString *) message
{
    
    NSLog(@"[%@ parseMessage] : start......", [self class]);
    
    NSMutableDictionary * result = nil;
    if(message)
    {
        if([message hasPrefix:@"^&*"] && [message hasSuffix:@"^&*"])
        {
            NSRange range = {3,[message length]-6};
            NSString * str1 = [message substringWithRange:range];
            NSArray * array1 = [str1 componentsSeparatedByString:@"(#$)"];
            if([array1 count] > 0)
            {
                result = [[NSMutableDictionary alloc] init];
                for(int i = 0; i < [array1 count]; i++ )
                {
                    NSArray * array2 = [array1[i]  componentsSeparatedByString:@"="];
                    if([array2 count] == 2)
                    {
                        [result setObject:array2[1] forKey:array2[0]];
                    }
                    else
                    {
                        NSLog(@"[%@ parseMessage] : the format of message is wrong1!!!!!!", [self class]);
                        result = nil;
                        break;
                    }
                }
                
            }
            else
            {
                NSLog(@"[%@ parseMessage] : the format of message is wrong2!!!!!!", [self class]);
            }
        }
        else
        {
            NSLog(@"[%@ parseMessage] : the format of message is wrong3!!!!!!", [self class]);
        }
    }
    else
    {
        NSLog(@"[%@ parseMessage] : the message is nil!!!!!!", [self class]);
    }
    
    NSLog(@"[%@ parseMessage] : end......", [self class]);
    
    return result;
}



+ (NSString *) packageMessage : (NSDictionary *) netMessages
{
    NSLog(@"[%@ packageMessage] : start......", [self class]);
    
    NSMutableString * result =nil;
    
    if(netMessages && [netMessages count] > 0){
        
        result = [NSMutableString stringWithString:@"^&*"];
        
        for(id key in netMessages)
        {
            NSString * str = [NSString stringWithFormat:@"%@=%@",key,[netMessages objectForKey:key]];
            [result appendString:str];
            [result appendString:@"(#$)"];
        }
        NSRange range = {[result length]-4,4};
        [result replaceCharactersInRange:range withString:@"^&*"];
        
    }
    
    NSLog(@"[%@ packageMessage] : the package result is %@",[self class],result);
    NSLog(@"[%@ packageMessage] : end......", [self class]);
    
    
    return result;
}


+(NSDictionary *) parseMessgae:(NSString *)message withKey:(NSString *)key
{
    NSLog(@"[%s [%d]] : start......", __func__,__LINE__);
    
    NSMutableDictionary * result = nil;
    if(message)
    {
        if([message hasPrefix:@"^&*"] && [message hasSuffix:@"^&*"])
        {
            NSRange range = {3,[message length]-6};
            NSString * cipherText = [message substringWithRange:range];
            
            //解密
            NSString * plainText = [AES aes256_decrypt:key Decrypttext:cipherText];

            NSArray * array1 = [plainText componentsSeparatedByString:@"(#$)"];
            if([array1 count] > 0)
            {
                result = [[NSMutableDictionary alloc] init];
                for(int i = 0; i < [array1 count]; i++ )
                {
                    NSArray * array2 = [array1[i]  componentsSeparatedByString:@"="];
                    if([array2 count] == 2)
                    {
                        [result setObject:array2[1] forKey:array2[0]];
                    }
                    else
                    {
                        NSLog(@"[%s [%d]] : the format of message is wrong1!!!!!!", __func__,__LINE__);
                        result = nil;
                        break;
                    }
                }
                
            }
            else
            {
                NSLog(@"[%s [%d]] : the format of message is wrong2!!!!!!", __func__,__LINE__);
            }
        }
        else
        {
            NSLog(@"[%s [%d]] : the format of message is wrong3!!!!!!", __func__,__LINE__);
        }
    }
    else
    {
        NSLog(@"[%s [%d]] : the message is nil!!!!!!", __func__,__LINE__);
    }
    
    NSLog(@"[%s [%d]] : end......", __func__,__LINE__);
    
    return result;
}


+(NSString *) packageMessage:(NSDictionary *)netMessages withKey:(NSString *)key
{
    NSLog(@"[%s [%d]] : start......", __func__,__LINE__);
    
    NSString * result =nil;
    
    if(netMessages && [netMessages count] > 0){
        
        NSMutableString * tempStr = [NSMutableString stringWithString:@""];
        
        for(id key in netMessages)
        {
            NSString * str = [NSString stringWithFormat:@"%@=%@",key,[netMessages objectForKey:key]];
            [tempStr appendString:str];
            [tempStr appendString:@"(#$)"];
        }
        NSRange range = {0,[tempStr length]-4};
        tempStr = (NSMutableString *)[tempStr substringWithRange:range];
        
        //加密
        NSString * cipherText = [AES aes256_encrypt:key Encrypttext:tempStr];
        
        result = [NSString stringWithFormat:@"^&*%@^&*",cipherText];
    }
    
    NSLog(@"[%@ packageMessage] : the package result is %@",[self class],result);
    
    NSLog(@"[%s [%d]] : end......", __func__,__LINE__);
    
    
    return result;
}



+(NSData *) packageFileData:(NSData *) fileData
{
    NSMutableData * result = [[NSMutableData alloc] init];
    
    int fileLength = [fileData length];
    
    NSString * lengthStr = [NSString stringWithFormat:@"%10d",fileLength];
    
    [result appendData:[lengthStr dataUsingEncoding:NSUTF8StringEncoding]];
    [result appendData:fileData];
    
    return result;
    
//    int dataLength = [result length];
//    
//    if(dataLength < 2*BUFFER_SIZE)
//    {
//        int fillLength = 2*BUFFER_SIZE - dataLength;
//        int8_t * fillBytes = (int8_t *) malloc(fillLength*sizeof(int8_t));
//        for(int i = 0;i < fillLength;i++)
//        {
//            fillBytes[i] = '\0';
//        }
//        [result appendBytes:fillBytes length:fillLength];
//        
//    }
//    
//    return nil;
    
}

+(NSData *) parsePackageData:(NSData *) packageData
{
    if(!packageData || [packageData length]!= 2*BUFFER_SIZE)
        return nil;
    
    NSRange lengthRange = {3,4};
    NSData * lengthData = [packageData subdataWithRange:lengthRange];
    int length = [[[NSString alloc]initWithData:lengthData encoding:NSUTF8StringEncoding] intValue];
    
    NSRange fileRange = {10,length};
    
    NSData * fileData = [packageData subdataWithRange:fileRange];
    
    return fileData;
}


@end
