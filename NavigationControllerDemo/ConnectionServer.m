//
//  ServerNetwork.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "ConnectionServer.h"


#define LENGTH_OF_LISTEN_QUEUE 20

@implementation ConnectionServer


-(instancetype) initWithPort: (int) port
{
    NSLog(@"[%@ initWithPort start......]",[self class]);
    
    if(self = [super init])
    {
        _serverSocket = [[ServerSocket alloc] initWithPort:port];
        
        if(_serverSocket == nil)
        {
            NSLog(@"[%@ initWithPort] server create failed!!!!!!",[self class]);
            return nil;
        }
        _port = [_serverSocket port];
        
        _clientSocketArray = [[NSMutableArray alloc] initWithCapacity:10];
        
        _ip = [Network getIPAddress:YES];
        
        _connNum = 0;
        
        _isSharing = false;
    }
    
    NSLog(@"[%@ initWithPort end......]",[self class]);
    
    return self;
}


-(void) acceptAndHandleConnection
{
    NSLog(@"[%@ acceptAndHandleConnection] : start......",[self class]);
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        while(_serverSocket){
            
            NSLog(@"[%@ acceptAndHandleConnection] : start accepting......",[self class]);
            
            Socket * socket = [_serverSocket accept];
            
            NSLog(@"serverSocket id :%d",[_serverSocket serverSocket]);
            
            // socket == nil socket接受失败，serverSocket可能被系统回收，重建服务器
            if(!socket)
            {
                NSLog(@"[%@ acceptAndHandleConnection] : socket accept failed!!!!!!",[self class]);
                
                NSLog(@"[%@ acceptAndHandleConnection] : the server socket has been destroyed!!!!!",[self class]);
              
            //    [self.delegate handleServerClose];
                
                break;
            }
            
            NSLog(@"[%@ acceptAndHandleConnection] : one client connect!!!!!!",[self class]);
            
           // dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                
                [self handleConnection:socket];
                
            });
            
        }
    });
    
    NSLog(@"[%@ acceptAndHandleConnection] : end......",[self class]);
    
}

- (void) handleConnection:(Socket *)socket
{
    NSLog(@"[%@ handleConnection] : start......",[self class]);
    
   
    
    NSString * str = [socket readStr];
    
    // 异常 ： str == nil ,socket被回收或者接受失败，关闭socket，并返回上一层
    if(!str)
    {
        NSLog(@"[%@  %s] : resuest file str is nil",[self class],__func__);
        
        [socket close];
        
        NSLog(@"[%@ handleConnection] : end......",[self class]);
        
        return;
    }
    
    // 解析请求字符串
    NSDictionary * dic = [Network parseMessgae:str withKey:self.key];
    // 异常 ： dic == nil 请求字符串格式不正确，解析出错，关闭socket，并返回上一层
    if(!dic)
    {
        NSLog(@"[%@ handleConnection] : parse failed",[self class]);
        
        [socket close];
        
        NSLog(@"[%@ handleConnection] : end......",[self class]);
        
        return;
    }
    
    NetMessage netMessage = [[dic objectForKey:@"NetMessage"] intValue];
    
    // netMessag字段为request ，请求正确，开始响应客户端
    if(netMessage == NetMessageConnection_Request)
    {
        NSLog(@"[%@ acceptAndHandleConnection] : one client request file!!!!!!",[self class]);
        
        extern File * file;
        
        //服务器取消分享
        if((!self.isSharing) || (!file) || ![file fileHandle])
        {
            NSLog(@"[%@ acceptAndHandleConnection] : NO Sharing!!!!!!",[self class]);
            
            // 封装响应字符串
            netMessage = NetMessageConnection_NoSharing;
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            
            [dic setValue: [NSString stringWithFormat:@"%d",netMessage] forKey:@"NetMessage"];
            
            NSString * str = [Network packageMessage:dic withKey:self.key];
            
            // 发送响应字符串
            NSInteger length = [socket write:[str UTF8String] withLength:[str length]];
            
            // 异常 ： 发送失败，socket异常关闭
            if(length == -1)
            {
                NSLog(@"[%@  %s] : NO Sharing str write failed ",[self class],__func__);
              
                [socket close];
            }
            
        }
        
        //连接数已满
        else if(self.connNum >= MAXCONNECTNUM)
        {
            NSLog(@"[%@ acceptAndHandleConnection] : connNum is Max!!!!!!",[self class]);
            
            // 封装响应字符串
            netMessage = NetMessageConnection_MaxNum;
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            
            [dic setValue: [NSString stringWithFormat:@"%d",netMessage] forKey:@"NetMessage"];
            
            NSString * str = [Network packageMessage:dic withKey:self.key];
            
            // 发送
            NSInteger length = [socket write:[str UTF8String] withLength:[str length]];
            
            // 异常 ： 发送失败，socket异常关闭
            if(length == -1)
            {
                NSLog(@"[%@  %s] : connNum is Max str write failed ",[self class],__func__);
                
                [socket close];
            }
        }
        
        // 文件传输请求接受，并准备传输文件
        else 
        {
            NSLog(@"[%@ acceptAndHandleConnection] : allow file transmission!!!!!!",[self class]);
            
            // 封装响应字符串
            netMessage = NetMessageConnection_OK;
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            
            [dic setValue: [NSString stringWithFormat:@"%d",netMessage] forKey:@"NetMessage"];
            
            NSString * str = [Network packageMessage:dic withKey:self.key];
            
            // 发送响应字符串
            NSInteger length = [socket writeStr:str];
            
            // 异常 ： 发送失败，socket异常关闭
            if(length == -1)
            {
                NSLog(@"[%@  %s] : allow file tranmission write failed ",[self class],__func__);
                
                [socket close];
                
                NSLog(@"[%@ handleConnection] : end......",[self class]);
                
                return;
            }
            
        
            
            TransmissionServer * transmissionServer = [[TransmissionServer alloc] initWithFile:file withConnectionSocket:socket];
            [transmissionServer setKey:self.key];
            self.connNum ++;
            [self.clientSocketArray addObject:transmissionServer];
            
            [transmissionServer transmission];
            
            self.connNum --;
            [self.clientSocketArray removeObject:transmissionServer];
            
        }
        
    }
    
    NSLog(@"[%@ handleConnection] : end......",[self class]);

}


-(bool)closeAll
{
    NSLog(@"[%@ closeAll ] start......",[self class]);
    
    bool result = NO;
    
    if([_serverSocket close])
    {
        for(Socket * socket in self.clientSocketArray)
        {
            [socket close];
        }
        self.connNum = 0;
        self.isSharing = NO;
        result = YES;
    }
    NSLog(@"[%@ closeAll ] end......",[self class]);
    
    return result;
}




-(bool) close
{
    
    NSLog(@"[%@ close ] start......",[self class]);
    
    bool result = NO;
    
    if([_serverSocket close])
    {
        self.connNum = 0;
        self.isSharing = NO;
        self.key = nil;
        result = YES;
    }
    NSLog(@"[%@ close ] end......",[self class]);
    
    return result;
}

- (bool) isClosed
{
    return [self.serverSocket isClosed];
    
}







@end
