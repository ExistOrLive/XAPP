//
//  QRCodeViewController.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/5.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    
    NSLog(@"[%@ viewDidLoad] start......",[self class]);
    
    [super viewDidLoad];
    
    UIBarButtonItem * returnBarButton = [[UIBarButtonItem alloc] initWithTitle:@"XAPP" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    UIBarButtonItem * returnBarButtonImage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back@3x.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    NSArray * barButtonArray = [NSArray arrayWithObjects:returnBarButtonImage,returnBarButton,nil];
    
    self.navigationItem.leftBarButtonItems = barButtonArray;
    
    if(self.qrImage != nil)
    {
        // 二维码不为空，设置服务器为可分享状态
        self.qrImageView.image = self.qrImage;
    }
    
    NSLog(@"[%@ viewDidLoad] end......",[self class]);
    
}

-(void) goBack
{
    NSLog(@"[%@ goBack] start......",[self class]);
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"Are you sure cancelling sharing" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
        
        NSLog(@"[%@ goBack] go back to root controller",[self class]);
        extern ConnectionServer * connectionServer;
        extern File * file;
        [connectionServer setIsSharing:NO];
        [connectionServer setKey:nil];
        file = nil;
        [self.navigationController popToRootViewControllerAnimated:YES];
    
    }];
    UIAlertAction * noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:yesAction];
    [controller addAction:noAction];
    [self presentViewController:controller animated:YES completion:nil];
    
    NSLog(@"[%@ goBack] end......",[self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
