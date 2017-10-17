//
//  ScanAVCapture.h
//  MOA
//
//  Created by 郑冰津 on 16/7/4.
//  Copyright © 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

///扫描二维码的硬件设置
@interface ScanAVCapture : NSObject
///第一步,判断用户是否开启了使用摄像头权限
- (void)canUseCamera:(void(^)(BOOL isCan))block;
///第二步,如果用户已经同意了调用相机权限(根据 isCan 判断),开始扫描,view必须为一个实例,scope为真正的扫描范围
- (void)scanImageSetView:(UIView *)view scope:(CGRect)scope back:(void(^)(NSString *data))block;
///停止扫描
- (void)stopScaning;
///开始扫描
- (void)startScaning;

@end
