//
//  Network.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/31.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <net/if.h>
#import "ifaddrs.h"
#import <arpa/inet.h>
#import "AES.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

// 连接请求及响应
typedef NS_ENUM(NSInteger, NetMessage) {
    
    NetMessageConnection_error = -1,
    NetMessageConnection_Request = 0,      // 请求连接
    NetMessageConnection_NoSharing = 1,    // 服务器未在分享状态
    NetMessageConnection_MaxNum = 2,       // 服务器连接数已满
    NetMessageConnection_OK = 3,           // 服务器允许连接
    NetMessageConnection_HasDownload = 4   // 文件已经下载过
    
};

@interface Network : NSObject



/**
 获取本机的IP地址
 @param preferIPv4 是否为IPv4地址
 @return   返回IP地址字符串
 **/

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

/**
 获取本机所有的相关IP信息
 @return 返回本机IP信息的散列表
 **/
+ (NSDictionary *)getIPAddresses;

/**
 解析客户端和服务端通信的信息
 @prama message 通信信息
 @return 将解析的结果封装在Dictionary中
 **/
+ (NSDictionary *) parseMessgae : (NSString *) message;

/**
 将想要传递的信息封装成可以传递的字符串信息
 @prama netmessage 保存在即将传递的信息
 @return 封装好的字符串
 **/
+ (NSString *) packageMessage : (NSDictionary *) netMessages;

/**
 解析客户端和服务端通信的信息
 @prama message 通信信息
 @prama key 秘钥
 @return 将解析的结果封装在Dictionary中
 **/
+ (NSMutableDictionary *) parseMessgae : (NSString *) message withKey:(NSString *) key;

/**
 将想要传递的信息加密，封装成可以传递的字符串信息
 @prama netmessage 保存在即将传递的信息
 @prama key 秘钥
 @return 封装好的字符串
 **/
+ (NSString *) packageMessage : (NSDictionary *) netMessages withKey:(NSString *) key;

/**
 将文件的数据分片加密，并封装成固定长度的数据包
 @fileData 文件的分片数据
 @return 固定长度的数据包
 **/
+ (NSData *) packageFileData:(NSData *) fileData;

/**
 解析固定长度的文件数据包并解密成明文的文件分片
 @packageData 文件数据包
 @return 明文文件分片数据
 **/
+ (NSData *) parsePackageData:(NSData *) packageData;

@end
