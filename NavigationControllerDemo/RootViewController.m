
//
//  RootViewController.m
//  NavigationControllerDemo
//
//  Created by 朱猛 on 2017/10/18.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

#pragma mark lifecycle
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame = CGRectMake(0,CGRectGetMaxY(frame)-49, CGRectGetMaxX(frame), 200) ;
    self.tabBar.frame = frame;
    
}

@end
