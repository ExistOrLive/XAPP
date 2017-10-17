//
//  ScanAVCapture.m
//  MOA
//
//  Created by 郑冰津 on 16/7/4.
//  Copyright © 2016年 zte. All rights reserved.
//

#import "ScanAVCapture.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanAVCapture ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>{
    void(^isCanUseCamera)(BOOL isCan);
    void(^scanStringBlcok)(NSString * stringValue);
    AVCaptureSession *_session;
    SystemSoundID soundID;
    NSString * oldString ;///代理回调2次,如果老值和新值一样就没有必要回调
}
@end

@implementation ScanAVCapture

- (void)dealloc{
    AudioServicesDisposeSystemSoundID(soundID);//释放资源
    NSLog(@"%s",__func__);
}

- (void)canUseCamera:(void(^)(BOOL isCan))block{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"第一次使用相机"]!=1) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"第一次使用相机"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        block(YES);
        return;
    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        block(YES);
    }else{
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Please open the camera in the setting"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                block(NO);
            }];
            UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }];
            [alertVC addAction:actionCancel];
            [alertVC addAction:actionSure];
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            [window.rootViewController presentViewController:alertVC animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tips" message:@"Please open the camera in the setting" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            [alert show];
            isCanUseCamera = block;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        [[UIApplication sharedApplication] openURL:url];
    }else{
        isCanUseCamera(NO);
    }
}

///第二步,如果用户已经同意了调用相机权限,开始扫描
- (void)scanImageSetView:(UIView *)view scope:(CGRect)scope back:(void(^)(NSString *data))block{
    NSAssert(view, @"外部没有一个view作为承载体");
    ///设置设备
    NSError *error=nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    ///设置 获取设备输入
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
    ///设置 获取设备输出
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    ///设置 捕获会话
    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    ///设置输出代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    ///设置 扫描到的type
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode]];
   // output.rectOfInterest = CGRectMake(x, y, width, height);///设置扫描范围
    ///设置展示的layer
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    layer.frame = view.bounds;
    [view.layer insertSublayer:layer atIndex:0];
    ///开始扫描
    [session startRunning];
    _session =session;///强引用,不然没有结果
    scanStringBlcok=block;
}
- (void)stopScaning{
    if (_session.isRunning) {
        [_session stopRunning];
    }
}
- (void)startScaning{
    oldString = nil;
    if (!_session.isRunning) {
        [_session startRunning];
    }
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (!_session.isRunning) {
        return ;
    }
    [self stopScaning];
    NSString *stringValue = nil;
    if ([metadataObjects count]<=0) {
        scanStringBlcok(stringValue);
    }else {
        ///取第一个扫描的结果展示
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        if (!stringValue) {
            scanStringBlcok(stringValue);
        }else{
            [self playQRVoice];
            if (![oldString isEqualToString:stringValue]) {
                oldString = stringValue;
                scanStringBlcok(stringValue);
                NSLog(@"The result of Scanning is %@", stringValue);
            }
        }
    }
}

///音乐播放
- (void)playQRVoice {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"QRVoice.wav" withExtension:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
    AudioServicesPlaySystemSound(soundID);
    //    AudioServicesDisposeSystemSoundID(soundID);//释放资源
}

@end
