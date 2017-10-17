//
//  DownloadViewController.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/30.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientNetwork.h"
#import "FileShowViewController.h"
#import "AppDelegate.h"
#import "NSString+localized.h"

@interface DownloadViewController : UIViewController <ClientNetworkDelegate>

@property (strong, nonatomic) IBOutlet UITextField *ipField;
@property (strong, nonatomic) IBOutlet UITextField *portField;

@property (strong, nonatomic) IBOutlet UIButton *connectButton;

@property (strong, nonatomic) NSString * ip;
@property  int port;
@property (strong, nonatomic) NSString * key;

@property (strong, nonatomic) IBOutlet UIProgressView *processView;
@property (strong, nonatomic) IBOutlet UILabel *processText;

- (void) goback;


@end
