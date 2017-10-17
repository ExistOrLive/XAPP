
//
//  ServerSocket.m
//  NetWorkDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "ServerSocket.h"

#define LENGTH_OF_LISTEN_QUEUE 20


@implementation ServerSocket

- (instancetype) initWithPort:(int)port
{
    NSLog(@"[%@ initWithPort : start......]",self.class);
 
    if(self = [super init])
    {
        _port = port;
        
        // sockaddr_in 结构体 保存IP地址，port和协议家族
        struct sockaddr_in server_addr;
        bzero(&server_addr, sizeof(server_addr));
        server_addr.sin_addr.s_addr=INADDR_ANY;
        server_addr.sin_port=htons(_port);
        server_addr.sin_family=AF_INET;
        
        // 创建socket
        int serverSocketIdentifier=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
        if(serverSocketIdentifier<0){
            NSLog(@"[%@ initWithPort] : Create Socket Failed!!!!!!",self.class);
            return nil;
        }
        
        // 绑定端口
        while(bind(serverSocketIdentifier,(struct sockaddr *)&server_addr,sizeof(server_addr))){
            NSLog(@"[%@ initWithPort] : can not bind port %d!!!!!!",self.class,self.port);
            _port++;
            server_addr.sin_port=htons(_port);
        }
        
        //设置IP和端口复用
        int optvalue = true;
        socklen_t socklen = sizeof(int);
        int result = setsockopt(serverSocketIdentifier, SOL_SOCKET, SO_REUSEADDR, &optvalue, socklen);
        NSLog(@"[%s [%d]] : setsockopt result = %d",__func__,__LINE__,result);
        
        // 监听端口
        if(listen(serverSocketIdentifier,LENGTH_OF_LISTEN_QUEUE)){
            NSLog(@"[%@ initWithPort] : listen port Failed!!!!!!",self.class);
            return nil;
        }
        
        _serverSocket = serverSocketIdentifier;
        
         NSLog(@"[%@ initWithPort] : server create success!!!!!!",self.class);
        
        NSLog(@"[%@ initWithPort] : server create success %@ : %d !!!!!!",[self class],_ip,_port);
    }
   
    NSLog(@"[%@ initWithPort : end......]",self.class);
    
    return self;
}

- (Socket *) accept
{
    NSLog(@"[%@ accept : start......]",self.class);
    
    int clientSocketIdentifier = accept(self.serverSocket,NULL,(socklen_t)sizeof(struct sockaddr));
    
    if(clientSocketIdentifier < 0 || [self isClosed])
    {
        NSLog(@"errno = %d",errno);
        NSLog(@"[%@ accept] : server accept failed!!!!!!", [self class]);
        return nil;
    }
    
    NSLog(@"[%@ accept] : server accept success  %d!!!!!!", [self class],clientSocketIdentifier);
    
    Socket * socket = [[Socket alloc] initWithSocketIdentifier:clientSocketIdentifier];
    
    NSLog(@"[%@ accept : end......]",self.class);
    
    return socket;

}

- (bool) close
{
    if(close(self.serverSocket) == 0)
    {
        return YES;
    }
    else
        return NO;
}

- (bool) isClosed
{
    return (self.serverSocket == -1);
}


@end
