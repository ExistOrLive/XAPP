
//
//  Socket.m
//  NetWorkDemo
//
//  Created by zhumeng on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "Socket.h"

#define LENGTH_OF_LISTEN_QUEUE 20
#define BUFFER_SIZE 1024

@implementation Socket

- (instancetype) initWithIP: (NSString *) ip withPort: (NSInteger) port
{
    NSLog(@"[%@ initWithIP:withPort start......]",[self class]);
    
    if(self = [super init])
    {
        struct sockaddr_in addr;
        addr.sin_family=AF_INET;
        addr.sin_addr.s_addr=inet_addr([ip UTF8String]);
        addr.sin_port=htons(port);
        
        int clientSocketIdentifier=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
        if(clientSocketIdentifier == -1){
            NSLog(@"[%@ initWithIP:withPort] socket create failed!!!!!!",[self class]);
            return nil;
        }
        
        
        if(connect(clientSocketIdentifier, (struct sockaddr*)&addr,sizeof(addr)) < 0){
            NSLog(@"[%@ initWithIP:withPort] socket connect failed!!!!!!",[self class]);
            return nil;
            
        }
        NSLog(@"[%@ initWithIP:withPort] socket connect success!!!!!!",[self class]);
        
        _socket = clientSocketIdentifier;
        _ip = ip;
        _port = port;
        
    }
    
    NSLog(@"[%@ initWithIP:withPort start......]",[self class]);
    
    return self;
  
}

- (instancetype) initWithSocketIdentifier: (int) socket
{
    NSLog(@"[%@ initWithSocketIdentifier start......]",[self class]);
    
    if(self = [super init])
    {
        _socket = socket;
    }
    
    NSLog(@"[%@ initWithSocketIdentifier end......]",[self class]);
    
    return self;
}


- (NSInteger) read: (uint8_t *) bytes withLength: (NSInteger) length
{
    NSInteger resultLength = recv(self.socket, bytes, length, 0);
    
    if(resultLength == 0)
    {
        NSLog(@"errno = %d",errno);
    }
    
    NSLog(@"[%@ read: withlength %d]",[self class],resultLength);

    return resultLength;
}


- (NSInteger) write: (uint8_t *) bytes withLength: (NSInteger) length
{
    
//    int error;
//    int len = sizeof(int);
//    int result = getsockopt(self.socket,SOL_SOCKET, SO_ERROR, &error, &len);
//    NSLog(@"error = %d",error);
//    NSLog(@"errno = %d",errno);
//    if(result == -1)
//    {
//        NSLog(@"errno = %d",errno);
//        NSLog(@"error = %d",error);
//        return -1;
//    }
 
   
    

    
    NSInteger resultLength = -1;
   
    resultLength = (NSInteger)send(self.socket, bytes, length, 0);
    
    signal(SIGPIPE, SIG_IGN);
    
    
    
    NSLog(@"write errno = %d",errno);

    NSLog(@"[%@ write: withLength %ld]",[self class],(long)resultLength);
    
    return resultLength;

}

- (NSString *) readStr
{
   // int8_t bytes[BUFFER_SIZE];
    int8_t * bytes = (int8_t *)malloc((1024*10)*sizeof(int8_t));
    
    int socket = self.socket;
    
    NSInteger resultLength = (NSInteger)recv(socket, bytes, 1024*10, 0);
    
    // recv 长度为0 socket关闭
    if(resultLength == 0)
    {
        NSLog(@"[%@ %s: withLength %ld]",[self class],__func__,(long)resultLength);
        
        return nil;
    }
    
    printf("the response str is : %s\n",bytes);
    
    int8_t * buffer = (int8_t *) malloc ((resultLength + 1)*sizeof(int8_t));
    
    for(int i = 0; i < resultLength; i++)
    {
        buffer[i] = bytes[i];
    }
    buffer[resultLength] = '\0';
    
    NSString * str = [NSString stringWithUTF8String:buffer];
    
    free(bytes);
    free(buffer);
    
    NSLog(@"[%@ readStr: withLength %ld with str:%@]",[self class],(long)resultLength,str);
    
    return str;
}

- (NSInteger) writeStr:(NSString *)str
{
    NSInteger resultLength = -1;
    @try {
        resultLength = send(self.socket,[str UTF8String],[str length],0);
    } @catch (NSException *exception) {
        NSLog(@"errno = %d",errno);
    }
   
    NSLog(@"[%@ writeStr: withLength %ld]",[self class],(long)resultLength);
    
    return resultLength;
}


- (bool) close
{
    
    if(close(self.socket) == 0)
    {
        _socket = -1;
        return YES;
    }
    else
        return NO;
}

- (bool) isClosed
{
    return NO;
}



@end
