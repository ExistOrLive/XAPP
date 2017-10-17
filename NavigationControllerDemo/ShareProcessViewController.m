//
//  ShareProcessViewController.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/31.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "ShareProcessViewController.h"

@interface ShareProcessViewController ()

@end

@implementation ShareProcessViewController


- (void)viewDidLoad
{
    NSLog(@"[%@ viewDidLoad start......]",self.class);
    
    [super viewDidLoad];
    
    NSString * ip = [Network getIPAddress:YES];
    extern int port;
    NSLog(@"%@:%d",ip,port);
    
    if([ip isEqualToString:@"0.0.0.0"])            // ip地址获取失败
    {
        NSLog(@"[%@ viewDidLoad get ip failed......]",self.class);
        
        [self.startButton setEnabled:NO];
        
        // 生成警告视图 ， 提醒用户IP地址获取失败
        UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"get ip failed" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        
       return;
    }
    
    [self.ipField setText:ip];
    [self.portFiled setText:[NSString stringWithFormat:@"%d",port]];
    [self.startButton setEnabled:YES];
    
    NSLog(@"[%@ viewDidLoad end......]",self.class);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startClicked:(id)sender {
    
    NSLog(@"[%@ startClicked start......]",self.class);
    /*
    extern bool isSharing;
    extern NSData * fileData;
  
    isSharing = YES;
    fileData = self.Data;
    */
    [self.startButton setEnabled: NO];

    NSLog(@"[%@ startClicked end......]",self.class);
}



@end
