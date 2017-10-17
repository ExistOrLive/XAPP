//
//  Socket.h
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


@interface Socket : NSObject

@property(readonly) int socket;

@property(atomic,copy,readonly) NSString * ip;

@property(readonly) NSInteger port;

- (instancetype) initWithIP: (NSString *) ip withPort: (NSInteger) port;

- (instancetype) initWithSocketIdentifier: (int) socket;

- (NSInteger) read: (uint8_t *) bytes withLength: (NSInteger) length;

- (NSInteger) write: (uint8_t *) bytes withLength: (NSInteger) length;

- (NSString * ) readStr;

- (NSInteger) writeStr:(NSString *) str;

- (bool) close;


@end
