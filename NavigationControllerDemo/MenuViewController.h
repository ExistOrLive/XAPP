
//
//  MenuViewController.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareViewController.h"
#import "DownloadViewController.h"
#import "FileListTableViewController.h"
#import "ScanQRCode_VC.h"
#import <CoreTelephony/CTCellularData.h>
#import "NSString+localized.h"


@interface MenuViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton * shareButton;
@property (strong, nonatomic) IBOutlet UIButton * downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *localFileButton;

@end
