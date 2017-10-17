//
//  ConfigScanViewController.h
//  MOA
//
//  Created by GaoShuiBo on 15/9/11.
//  Copyright (c) 2015年 zte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DownloadViewController.h"
#import "Network.h"

typedef NS_ENUM(NSUInteger, ScanScence) {
    ScanScenceDefaultScan           = 0,   ///正常的扫一扫
    ScanScenceOfDownLoadConfig      = 1<<1,///扫描的服务器的配置文件.扫描有结果直接返回
} NS_ENUM_AVAILABLE_IOS(7_0);

@interface ScanQRCode_VC : UIViewController
///当此类在alloc和New的时候需要定义一下下面的枚举,不从下载设置进入此类的设置为ScanScenceDefaultScan
@property (nonatomic,assign)ScanScence scanScence;

@end



