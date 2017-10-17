//
//  AppDelegate.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/28.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "Tool.h"
#import "File.h"
#import "Network.h"
#import "ConnectionServer.h"
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <CoreTelephony/CTCellularData.h>
#import "NSString+localized.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,ConnectionServerDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) timeIntervalHandle;

@end

