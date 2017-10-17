//
//  ConfigScanViewController.m
//  MOA
//
//  Created by GaoShuiBo on 15/9/11.
//  Copyright (c) 2015年 zte. All rights reserved.
//

#import "ScanQRCode_VC.h"
#import "ScanView.h"
#import "ScanAVCapture.h"

#define PhotoButtonWidth                                        55
#define PhotoButtonHeigth                                       44
#define ERROR_TIPS_Duration 4


@interface ScanQRCode_VC ()<UINavigationControllerDelegate>

{
    ScanAVCapture *_scanDevice;
    ///扫描出来的ID
    NSString *opearteId;
    ///判断30秒之后是否有了回调,若没有回调,则显示超时的提示
    BOOL isTimeOut;

    
    ///扫描出来的数据
    NSString *scanData;
    SystemSoundID soundID;
}
@property (nonatomic,strong)NSTimer *timer;

@end

@implementation ScanQRCode_VC

- (void)dealloc{
    NSLog(@"%s",__func__);
    
   
    
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self clearUISet];
    [self stopScanImage];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startScanImage];
    NSLog(@"frame1[%@] frame2[%@]", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(((ScanView *)[self.view viewWithTag:577]).frame));
}

- (void)backReturn:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Scan QR Code";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor grayColor];
    
    UIScreen * screen = [UIScreen mainScreen];
    CGFloat ScreenWidth = [screen bounds].size.width;
    CGFloat ScreenHeight = [screen bounds].size.height;
    
    //扫描UI设置
    ScanView *sView = [[ScanView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    sView.tag = 577;
    [self.view addSubview:sView];
    
    ///扫描调用硬件设置
    _scanDevice = [ScanAVCapture new];///强引用一下,因为AVCaptureSession弱引用
    __weak typeof(self)weakSelf = self;
    __weak typeof(_scanDevice)weakScan = _scanDevice;
    [_scanDevice canUseCamera:^(BOOL isCan) {
        if (isCan) {
            [sView startAnimation];
            [weakScan scanImageSetView:weakSelf.view scope:CGRectMake(ScreenWidth/2 - 150, 100, 300, 300) back:^(NSString *data) {
//                NSLog(@"----调用了几次?");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf judgeToDoSomeThingWithResult:data];
                });
            }];
        }else{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
  
}


/**
 解析扫描的结果，并根据结果作出相应的操作
 @prama value 扫描结果字符串
 **/
- (void)judgeToDoSomeThingWithResult:(NSString *)value{
   
    NSLog(@"%@ judgeToDoSomeThingWithResult start......" ,[self class]);

    scanData = value;
    [self stopScanImage];
 
    // 扫描结果为nil ，扫描失败
    if (!value)
    {
        NSLog(@"%@ judgeToDoSomeThingWithResult scan QRCode error1!!!!!!" ,[self class]);
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"NO QRCode was found" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK,I Know!" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        
        [self performSelector:@selector(startScanImage) withObject:nil afterDelay:ERROR_TIPS_Duration];
    

    }
    else
    {
        NSDictionary * dic = [Network parseMessgae:value];
        
        //扫描结果格式不正确 ，扫描失败
        if(!dic)
        {
            NSLog(@"%@ judgeToDoSomeThingWithResult scan QRCode error2!!!!!!" ,[self class]);
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"scan QRCode error" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK,I Know!" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            
            [self performSelector:@selector(startScanImage) withObject:nil afterDelay:ERROR_TIPS_Duration];

        }
        // 扫描成功
        else
        {
            NSString * ipText = [dic objectForKey:@"ip"];
            NSString * portText = [dic objectForKey:@"port"];
            int port = [portText intValue];
            NSString * key = [dic objectForKey:@"key"];
            
            NSLog(@"%@ judgeToDoSomeThingWithResult scan QRCode success......" ,[self class]);
            
            DownloadViewController * controller = [[DownloadViewController alloc] init];
            [controller setIp:ipText];
            [controller setPort:port];
            [controller setKey:key];
            [self.navigationController pushViewController:controller animated:YES];

        }
        
        
    }
    
    NSLog(@"%@ judgeToDoSomeThingWithResult end......" ,[self class]);
  
}


- (void)timeOutOfQRCode
{
    if (isTimeOut)
    {
        NSLog(@"Scan request time out");
    }
    
    [self clearUISet];
    
    [self performSelector:@selector(startScanImage) withObject:nil afterDelay:ERROR_TIPS_Duration];
}

- (void)clearUISet
{
    ///有了数据,没有超时
    isTimeOut = NO;
    ///停止定时器
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
 
}

- (void)startScanImage
{
    ScanView *sView = (ScanView *)[self.view viewWithTag:577];
    [sView startAnimation];
    sView.backgroundColor = [UIColor clearColor];
    [_scanDevice startScaning];
}
- (void)stopScanImage
{
    ScanView *sView = (ScanView *)[self.view viewWithTag:577];
    [sView stopAnimation];
    sView.backgroundColor = [UIColor grayColor];
    [_scanDevice stopScaning];
}




@end



