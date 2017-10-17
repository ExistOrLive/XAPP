//
//  ServerNetwork.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerSocket.h"
#import "Socket.h"
#import "Network.h"
#import "TransmissionServer.h"

#define MAXCONNECTNUM 5

@protocol ConnectionServerDelegate <NSObject>

@required

-(void)handleServerClose;

@end

@interface ConnectionServer : NSObject
{
    dispatch_queue_t queue;
}

@property (strong,readonly) ServerSocket * serverSocket;

@property (strong,readonly) NSMutableArray* clientSocketArray;


@property (readonly) int port;

@property (strong,readonly) NSString * ip;

@property (strong,atomic) NSString * key;

@property int connNum;

@property (atomic) bool isSharing;

@property (strong) id delegate;





- (instancetype) initWithPort: (int) port;

- (void) acceptAndHandleConnection;

- (bool) close;

- (bool) closeAll;

- (void) handleConnection: (Socket *) socket;

- (bool) isClosed;




@end


