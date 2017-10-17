//
//  DownloadViewController.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/30.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController (){
    ClientNetwork * client;
}

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    
    NSLog(@"%@ viewDidload start......", [self class]);
    
    [super viewDidLoad];
    
    self.navigationItem.title=@"download".localizedString;
    [self.connectButton setTitle:@"connection".localizedString forState:UIControlStateNormal];
    
    if(self.ip != nil && self.port != 0)
    {
         NSLog(@"%@ viewDidload ip and port not nil......", [self class]);
         NSLog(@"%@ viewDidload%d",self.ip ,self.port);
        
        self.ipField.text = self.ip;
        self.portField.text = [NSString stringWithFormat:@"%d",self.port];
        [self.ipField setEnabled:NO];
        [self.portField setEnabled:NO];
    }
    else
    {
        NSLog(@"%@ viewDidload ip or port is nil ......", [self class]);
      
    }
    
    UIBarButtonItem * returnBarButton = [[UIBarButtonItem alloc] initWithTitle:@"XAPP" style:UIBarButtonItemStylePlain target:self action:@selector(goback)];
    UIBarButtonItem * returnBarButtonImage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back@3x.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    NSArray * barButtonArray = [NSArray arrayWithObjects:returnBarButtonImage,returnBarButton,nil];
    
    self.navigationItem.leftBarButtonItems = barButtonArray;

    
    NSLog(@"%@ viewDidload end......", [self class]);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)editEnd:(id)sender {
    [self.ipField resignFirstResponder];
    [self.portField resignFirstResponder];
}


- (IBAction)connectClicked:(id)sender
{
    
    NSLog(@" %@ connectClicked : start.....",self.class);
    
    // 收起软键盘
    [self.ipField resignFirstResponder];
    [self.portField resignFirstResponder];
    
    if(self.ip == nil || self.port == 0){

        // 检验 IP 和 port 是否为空
        NSString * ipStr = self.ipField.text;
        NSString * portStr = self.portField.text;
        
        if([ipStr length]==0||[portStr length]==0){
            NSLog(@" %@ connectClicked : ip or port is nil.....",self.class);
            UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"ip or port is nil" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        self.ip = ipStr;
        self.port = [portStr intValue];
        
    }
    
    if(client)
    {
        UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"you have clicked it" message:@"if you want download other file,please go back" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * yesAction=[UIAlertAction actionWithTitle:@"Yes, I go back!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction * noAction = [UIAlertAction actionWithTitle:@"No, I will stay here!" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    // 创建socket客户端 ，并连接服务器端
    client = [[ClientNetwork alloc] initWithIP:self.ip withPort:self.port];
    [client setDelegate:self];
    [client setKey:self.key];
    
    
    if(!client)
    {
        NSLog(@" %@ connectClicked : client connect failed!!!!!!",self.class);
        
        UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"connect failed" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    else
    {
        NSLog(@" %@ connectClicked : connect success......",self.class);
        
        NetMessage netMessage = [client requestFile];
        
        switch(netMessage)
        {
            case NetMessageConnection_MaxNum :
            {
                UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"The connection number of server is max" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            }
                break;
                
            case NetMessageConnection_NoSharing:
            {
                UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"The server is not sharing" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            }
                break;
            
            case NetMessageConnection_OK :
            {
                extern ClientNetwork * clientNetwork;
                clientNetwork = client;
                
                UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"request success,please be ready for receiving file" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        [client acceptFile];
                    });
                
                }];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
                
                
            }
                
            case NetMessageConnection_error:
            {
                UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"the network communication suspend with exception" message:@"please check out th network and the server , try again" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            }
                break;
            case NetMessageConnection_Request:
                break;
            case NetMessageConnection_HasDownload:
                break;
                
        }
    
       
    }
    
    NSLog(@" %@ connectClicked : end.....",self.class);
    
}

- (void) goback
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) updateProcess:(float)process
{
    [self.processText setText:[NSString stringWithFormat:@"%0.1f%%",process]];
    [self.processView setProgress:process/100];
}

-(void) showResult:(bool)result withFile:(File *)file
{
    if(result)
    {
        if(file)
        {
            NSLog(@"[%@ showResult:withFile]: file download success!!!!!!",[self class]);
            FileShowViewController * controller = [[FileShowViewController alloc] init];
            [controller setFile:file];
            [self.navigationController pushViewController:controller animated:YES];
            
        }
        else
        {
            NSLog(@"[%@ showResult:withFile]: the file is nil!!!!!!",[self class]);
        }
    }
    else
    {
        NSLog(@"[%@ showResult:withFile]: file download failed!!!!!!",[self class]);
        UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"file download failed" message:@"please try again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

-(void) handleError
{
    NSLog(@"[%@ %s [%d]]: some error happened before tranmission!!!!!!",[self class],__func__,__LINE__);
    UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"some error happend" message:@"please try again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) tranmissionSuspend
{
    NSLog(@"[%@ %s [%d]]: file tranmissison suspend!!!!!!",[self class],__func__,__LINE__);
    UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"some error happend when tranmission" message:@"please try again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}





@end
