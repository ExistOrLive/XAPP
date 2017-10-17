//
//  MenuViewController.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "MenuViewController.h"


@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.navigationItem.title = @"XAPP";
    
    [self.shareButton setTitle:@"share".localizedString forState:UIControlStateNormal];
    [self.downloadButton setTitle:@"download".localizedString forState:UIControlStateNormal];
    [self.localFileButton setTitle:@"local file".localizedString forState:UIControlStateNormal];
    
    CTCellularData * cellularData = [[CTCellularData alloc] init];
    
    cellularData.cellularDataRestrictionDidUpdateNotifier =^(CTCellularDataRestrictedState state)
    {
        
        switch(state)
        {
            case kCTCellularDataRestricted : NSLog(@"restricted"); break;
            case kCTCellularDataNotRestricted : NSLog(@"not restricted"); break;
            case kCTCellularDataRestrictedStateUnknown : NSLog(@"unknown"); break;
        }
        
    };
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 操作方法
/**
 点击share按钮
 **/
- (IBAction)shareClicked:(id)sender
{
    NSLog(@"%@ shareClicked start......",[self class]);
    
    ShareViewController * controller = [[ShareViewController alloc]init];
    [self.navigationController pushViewController: controller animated:YES];
    
    NSLog(@"%@ shareClicked end......",[self class]);
}

/**
 点击download按钮
 **/
- (IBAction)downloadClicked:(id)sender
{
    NSLog(@"%@ downloadClicked start......",[self class]);
    
    ScanQRCode_VC * controller = [[ScanQRCode_VC alloc] init];
    [self.navigationController pushViewController: controller animated:YES];
    
    NSLog(@"%@ downloadClicked end......",[self class]);
}

/**
 点击localFile按钮
 **/
-(IBAction) fileClicked :(id) sender
{
    NSLog(@"%@ fileClicked start......",[self class]);

    FileListTableViewController * controller = [[FileListTableViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    
    NSLog(@"%@ fileClicked end......",[self class]);
}


@end
