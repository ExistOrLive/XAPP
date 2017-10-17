//
//  ShareProcessViewController.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/31.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Network.h"
#import "ConnectionServer.h"

@interface ShareProcessViewController : UIViewController{
    
}

@property (strong, nonatomic) IBOutlet UITextField *ipField;
@property (strong, nonatomic) IBOutlet UITextField *portFiled;
@property (strong, nonatomic) IBOutlet UIButton *startButton;

@property (strong, nonatomic) NSData * Data;

@end
