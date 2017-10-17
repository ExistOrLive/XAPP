//
//  FileShowViewController.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/5.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "FileShowViewController.h"

@interface FileShowViewController ()

@end

@implementation FileShowViewController

- (void)viewDidLoad
{
    
    NSLog(@"%@ viewDidLoad start......", [self class]);
    
    [super viewDidLoad];
    
    self.navigationItem.title = self.file.md5;
    
    NSString * absolutePath = [Tool getDownloadFilePathWithName:self.file.filePath];
   
    UIImage * image = [[UIImage alloc] initWithContentsOfFile:absolutePath];
    
    self.imageView.image = image;
    
    NSLog(@"%@ viewDidLoad end......", [self class]);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
