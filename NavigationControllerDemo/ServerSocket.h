//
//  ServerSocket.h
//  NetWorkDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/un.h>
#import <arpa/inet.h>
#import <stdio.h>
#import <errno.h>
#import "Socket.h"
#import "Network.h"

@interface ServerSocket : NSObject

@property(readonly) int serverSocket;

@property(atomic,copy,readonly) NSString * ip;

@property(readonly) int port;


- (instancetype) initWithPort:(int) port;

- (Socket *) accept;

- (bool) close;

- (bool) isClosed;



@end
