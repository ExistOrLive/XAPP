//
//  FileListTableViewController.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/4.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"
#import "FileShowViewController.h"
#import "File.h"
#import "NSString+localized.h"

@protocol FileListTableViewControllerDelegate <NSObject>

@required

- (void) handleSelectFile:(File *) file withController:(id)controller;

@end


@interface FileListTableViewController : UITableViewController

@property(nonatomic, strong ,readonly) NSMutableArray * fileList;

@property(nonatomic, strong) IBOutlet UIView * footerView;

@property(nonatomic, strong) UIBarButtonItem * rightBarButtonItem;

@property id delegate;

@property int state;    // 0 用于查阅 ，1 用于选择分享

@end
