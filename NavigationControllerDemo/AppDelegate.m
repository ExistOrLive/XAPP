//
//  AppDelegate.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/28.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "AppDelegate.h"


ConnectionServer * connectionServer;           //全局变量 ，socket服务器的文件描述符

ClientNetwork * clientNetwork;                        //全局变量 ，socket服务器的文件描述符

int port = 5680;                               //全局变量 ，维持本机服务器绑定的端口

NSString * ip = nil;                           //全局变量 ，维持本机的ip

File * file;                                   //全局变量 ，分享文件的二进制数据

NSMutableArray<File *> * downloadArray;        // 全局变量 ，用于保存下载的文件路径

UITabBarController * rootController;       // 全局变量 ，用于维持应用的容器导航视图控制器

NSTimer * networkTimer;                        // 计时器 检查网络

NSMutableArray * clientNetworkArray;           // 保存客户端连接的数组




@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark AppDelagate lifCycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    

    
    NSLog(@"[%@ didFinishLaunchingWithOptions start......]",self.class);
    
    CTCellularData * cellularData = [[CTCellularData alloc] init];
    
    cellularData.cellularDataRestrictionDidUpdateNotifier =^(CTCellularDataRestrictedState state)
    {
        
        switch(state)
        {
            case kCTCellularDataRestricted : NSLog(@"restricted"); break;
            case kCTCellularDataNotRestricted : NSLog(@"not restricted"); break;
            case kCTCellularDataRestrictedStateUnknown : NSLog(@"unknown"); break;
        }
        
    };
    
    CTCellularDataRestrictedState state = cellularData.restrictedState;
    
    switch(state)
    {
        case kCTCellularDataRestricted : NSLog(@"restricted"); break;
        case kCTCellularDataNotRestricted : NSLog(@"not restricted"); break;
        case kCTCellularDataRestrictedStateUnknown : NSLog(@"unknown"); break;
    }

    
    
    if(!clientNetworkArray)
    {
        clientNetworkArray = [[NSMutableArray alloc] init];
    }
    
    //检查网络，有局域网连接就建立服务器
    NSString * currentIp = [Network getIPAddress:YES];
    if(![currentIp isEqualToString:@"0.0.0.0"])
    {
       
        //创建服务器端，并监听端口
        connectionServer = [[ConnectionServer alloc] initWithPort:port];
        
        if(!connectionServer)
        {
            NSLog(@"[%@  acceptAndHandleConnection] : connectionServer build failed!!!!!!",self.class);
        }
        else
        {
            NSLog(@"[%@ acceptAndHandleConnection ] : connectionServer build success!!!!!!",self.class);
            ip = [connectionServer ip];
            port = [connectionServer port];
            NSLog(@"[%@ acceptAndHandleConnection ] : %@ : %d",[self class],ip,port);
            
            [connectionServer setDelegate:self];
            // 开始异步
            [connectionServer acceptAndHandleConnection];
        }
    }
  
    // 应用启动检查downloadArray.xml 文件是否存在 ，
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * downloadArrayPath = [Tool getDownloadArrayPath];
    
    // 存在则从文件中读取内容到 downlaodArray数组中,不存在则创建一个downloadArray数组对象和downloadArray.xml文件
    if([fileManager fileExistsAtPath: downloadArrayPath isDirectory: false])
    {
        NSData * data = [NSData dataWithContentsOfFile:downloadArrayPath];
        NSKeyedUnarchiver * unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        downloadArray =  [unArchiver decodeObjectForKey:@"downloadArray"];
        [unArchiver finishDecoding];
    }
    else
    {
        downloadArray=[NSMutableArray new];
        NSMutableData * data = [NSMutableData new];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:downloadArray forKey:@"downloadArray"];
        [archiver finishEncoding];
        [data writeToFile:downloadArrayPath atomically:YES];
      
    }
    
    // 设置 UITabBarViewController 为 UIWindow 的根控制器
    [self createTabBarViewController];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        networkTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timeIntervalHandle) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });
    
    NSLog(@"[%@ didFinishLaunchingWithOptions end......]",self.class);

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{

    NSLog(@"[%s [%d] : start......",__func__,__LINE__);
//    //关闭所有的client
//    for(ClientNetwork * client in clientNetworkArray)
//    {
//        [client close];
//    }
//    [clientNetworkArray removeAllObjects];
    
    //关闭定时器
    [networkTimer invalidate];
    networkTimer = nil;
    //关闭客户端
    if(clientNetwork != nil)
    {
        [clientNetwork close];
    }
    // 关闭服务器
    [connectionServer close];
    connectionServer = nil;
    //
    ip = nil;
    NSLog(@"[%s [%d] : end......",__func__,__LINE__);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
   
    NSLog(@"[%s [%d] : start......",__func__,__LINE__);
    //重启服务器
    NSString * currentIp = [Network getIPAddress:YES];
    if(![currentIp isEqualToString:@"0.0.0.0"])
    {
        connectionServer = [[ConnectionServer alloc] initWithPort:port];
        
        if(!connectionServer)
        {
            NSLog(@"[%s [%d] : connectionServer build failed!!!!!!",__func__,__LINE__);
        }
        else
        {
            NSLog(@"[%s [%d]: connectionServer build success!!!!!!",__func__,__LINE__);
            ip = [connectionServer ip];
            port = [connectionServer port];
            NSLog(@"[%s [%d]: %@ : %d",__func__,__LINE__,ip,port);
            
            [connectionServer setDelegate:self];
            [connectionServer acceptAndHandleConnection];
        }
    }
    
    //重启定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        networkTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timeIntervalHandle) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });

    
    NSLog(@"[%s [%d] : end......",__func__,__LINE__);

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    
    
}

#pragma  mark  NSTimeInterval 的执行方法
-(void) timeIntervalHandle
{
  //  NSLog(@"[%s [%d] : start......",__func__,__LINE__);
    
//    NSString * currentIp = [Network getIPAddress:YES];
//
//   // NSLog(@"[%s [%d] : currentIp = %@",__func__,__LINE__,currentIp);
//
//    if([currentIp isEqualToString:@"0.0.0.0"])
//    {
//        // 断网后第一次检查网络，如果还没有连接网络，则发出警告
//        if(nil == ip)
//        {
//            ip = @"0.0.0.0";
//            UIViewController * controller = [rootController topViewController];
//
//            if([controller isKindOfClass:[MenuViewController class]])
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"the iphone can not connect network".localizedString message:@"please check the network".localizedString preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction * yesAction = [UIAlertAction actionWithTitle:@"OK,I Know".localizedString style:UIAlertActionStyleDefault handler:nil];
//                    [alertController addAction:yesAction];
//                    [controller presentViewController:alertController animated:YES completion:nil];
//                });
//
//            }
//            else
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"the iphone can not connect network,we will goback to the main view" message:@"please check the network".localizedString preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction * yesAction = [UIAlertAction actionWithTitle:@"OK,I Know".localizedString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//                        [rootController popToRootViewControllerAnimated:YES];
//                    }];
//                    [alertController addAction:yesAction];
//                    [controller presentViewController:alertController animated:YES completion:nil];
//
//
//                });
//            }
//
//        }
//        // 一直没有网络连接
//        else if([ip isEqualToString:@"0.0.0.0"])
//        {
//
//        }
//        else
//        {
//            // 从连接到网络到没有连接网络
//            if(connectionServer)
//            {
//                [connectionServer closeAll];
//                connectionServer = nil;
//                ip = nil;
//                NSLog(@"[%s [%d] : the network disconnect",__func__,__LINE__);
//            }
//        }
//
//    }
//    else
//    {
//        // 网络切换
//        if(![currentIp isEqualToString:ip])
//        {
//            NSLog(@"[%s [%d] : the network has changed",__func__,__LINE__);
//            if(connectionServer)
//            {
//                [connectionServer closeAll];
//                connectionServer = nil;
//                ip = nil;
//            }
//
//            connectionServer = [[ConnectionServer alloc] initWithPort:port];
//
//            if(!connectionServer)
//            {
//                NSLog(@"[%s [%d] : connectionServer build failed!!!!!!",__func__,__LINE__);
//            }
//            else
//            {
//                NSLog(@"[%s [%d]: connectionServer build success!!!!!!",__func__,__LINE__);
//                ip = [connectionServer ip];
//                port = [connectionServer port];
//                NSLog(@"[%s [%d]: %@ : %d",__func__,__LINE__,ip,port);
//
//                [connectionServer setDelegate:self];
//                [connectionServer acceptAndHandleConnection];
//            }
//
//
//        }
//    }
    
  //   NSLog(@"[%s [%d] : end......",__func__,__LINE__);
}


#pragma mark other method
/**
 * @description 创建UITabBarController作为window的rootViewController,同时添加子视图控制器
 **/
- (void) createTabBarViewController
{
    rootController = [[UITabBarController alloc] init];
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame = CGRectMake(0, CGRectGetMaxY(frame)-49, CGRectGetMaxX(frame), 200.0) ;
    rootController.tabBar.frame = frame;
    
    MenuViewController * menuViewController = [[MenuViewController alloc]init];
    UINavigationController * homeViewController = [[UINavigationController alloc]initWithRootViewController:menuViewController];
    homeViewController.tabBarItem.image = [UIImage imageNamed:@"home.png"];
    homeViewController.tabBarItem.title = @"home".localizedString;
    
    UIViewController * settingViewController = [[UIViewController alloc]init];
    settingViewController.tabBarItem.image = [UIImage imageNamed:@"setting.png"];
    settingViewController.tabBarItem.title = @"setting".localizedString;
    
    [rootController addChildViewController:homeViewController];
    [rootController addChildViewController:settingViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
}


@end
