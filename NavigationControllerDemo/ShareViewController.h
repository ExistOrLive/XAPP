//
//  ShareViewController.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionServer.h"
#import "ShareProcessViewController.h"
#import "QRCodeTool.h"
#import "QRCodeViewController.h"
#import "MD5.h"
#import "FileListTableViewController.h"
#import "Tool.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Network.h"
#import "NSString+localized.h"

@interface ShareViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UINavigationBarDelegate,FileListTableViewControllerDelegate>{
    
}
@property (strong, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) IBOutlet UIButton *reselectButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *localFileButton;
@property (strong,nonatomic) UIImage * image;


@end
