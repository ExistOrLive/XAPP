//
//  TransmissionServer.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerSocket.h"
#import "Network.h"
#import "File.h"
#import "AES.h"

@interface TransmissionServer : NSObject

@property (strong,readonly) Socket * connectionSocket;           // 与客户段连接的socket

@property (strong,readonly) NSFileHandle * fileHandle;           //

@property (strong,readonly) File * file;                         //

@property (strong) NSString * key;                               // 本次传输的秘钥

/**
 @descrpiton 创建TransmissionSocket实例
 @prama file 即将传输的文件File实例
 @prama connectionSocket 与客户段相连接的socket
 @return TransmissionServer实例
 **/
- (instancetype) initWithFile: (File *) file withConnectionSocket:(Socket *)  connectionSocket;


#pragma mark  传输相关方法
/**
 * @description 文件正式传输前，交互文件的基本信息,服务端传递md5，length ，type等参数，客户端传递文件的起点指针location
 * @return 返回文件的起点指针， 如果为-1，则出现异常
 **/
- (unsigned long long) beforeTramission;

/**
 * @description 传输文件的主要代码
 **/
- (void) transmission;

@end
