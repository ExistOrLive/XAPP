//
//  ClientNetwork.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/30.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tool.h"

#import <CoreFoundation/CoreFoundation.h>
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/un.h>
#import <arpa/inet.h>
#import <stdio.h>
#import "Socket.h"
#import "Network.h"
#import "File.h"
#import "Tool.h"

extern NSMutableArray * downloadArray;

@interface ClientNetwork : NSObject

@property (strong,atomic) NSString * key;

@property (readonly,strong) NSString * ip;

@property (readonly) NSInteger port;

@property (readonly,strong) Socket * socket;

@property (strong) id delegate;


- (instancetype) initWithIP: (NSString *) ip withPort: (NSInteger) port;

- (NSInteger) requestFile;

- (void) acceptFile;

- (bool) close;


@end


@protocol ClientNetworkDelegate <NSObject>

@required

-(void) updateProcess:(float)process;

-(void) showResult:(bool) result withFile:(File *) file;

-(void) handleError;

-(void) tranmissionSuspend;

@end
