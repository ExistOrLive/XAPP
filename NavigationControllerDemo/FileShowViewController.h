//
//  FileShowViewController.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/5.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tool.h"
#import "File.h"

@interface FileShowViewController : UIViewController

@property(strong, nonatomic) File * file;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
