//
//  FileListTableViewController.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/4.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "FileListTableViewController.h"

@interface FileListTableViewController ()

@end

@implementation FileListTableViewController


// 重写父类的init方法
- (instancetype) init
{
    //将全局downloadArray 引入，作为列表视图的数据来源
    extern NSMutableArray * downloadArray;
    
    self = [super initWithStyle:UITableViewStylePlain];
    
    if(self)
    {
        _fileList = downloadArray;
    }
    
    return self;
}



- (void)viewDidLoad
{
    NSLog(@"[%@ viewDidLoad start......]",self.class);
    
    [super viewDidLoad];
    
    // 视图加载时 ，设置视图的导航栏属性
    self.navigationItem.title = @"file list".localizedString;
    
    if(_state == 0){
       self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    }
    
    // 向列表视图注册重用的UITableViewCell对象 ，设置列表的footer视图
       
    [self.tableView setTableFooterView: self.footerView];
    
     NSLog(@"[%@ viewDidLoad end......]",self.class);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (UIView *) footerView
{

    if(!_footerView)
    {   //加载FooterView.nib文件,(自定义视图需要手动加载)
        [[NSBundle mainBundle] loadNibNamed:@"FooterView" owner:self options:nil];
    }
    return _footerView;
}

// 设置导航栏的rightBarButtonItem
-(UIBarButtonItem *) rightBarButtonItem
{
    if(!_rightBarButtonItem)
    {
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit".localizedString style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemAction)];
    }
    
    return _rightBarButtonItem;
}

//设置rightBarButtonItem的点击事件
- (void) rightBarButtonItemAction
{
     NSLog(@"[%@ rightBarButtonItemAction start......]",self.class);
    
    if([self tableView: self.tableView numberOfRowsInSection:0] == 0)
        return;
    
    if([self.rightBarButtonItem.title isEqualToString:@"Edit".localizedString])
    {
        self.rightBarButtonItem.title = @"Done".localizedString;
        self.editing = YES;
    }
    else
    {
        self.rightBarButtonItem.title = @"Edit".localizedString;
        self.editing = NO;
    }
    
     NSLog(@"[%@ rightBarButtonItemAction end......]",self.class);
}

#pragma mark - Table view data source


// 返回列表视图的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileList count];
}

// 加载UITableViewCell
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"[%@ tableView:cellForRowAtIndexPath: start......]",self.class);

    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    
    File * file = [self.fileList objectAtIndex :[indexPath row] ];
    NSString * labelText = [NSString stringWithFormat:@"%@.%@",file.md5,file.fileType];
    NSString * detailText = [NSString  stringWithFormat:@"%@   %lld Byte",file.isVerificated? @"verificated".localizedString:@"unverificated".localizedString,file.length];
    
    cell.textLabel.text = labelText;
    cell.detailTextLabel.text = detailText;
    cell.imageView.image = [UIImage imageNamed:@"docIcon.png"];
    
    NSLog(@"[%@ tableView:cellForRowAtIndexPath: end......]",self.class);
    
    return cell;
    
}

// 更新UITableView
- (void) tableView :(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    NSLog(@"[%@ tableView:commitEditingStyle:forRowAtIndexPath: start......]",self.class);
    //如果是删除操作
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        // 删除对应的本地文件
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        File * file = [self.fileList objectAtIndex:indexPath.row ];
        NSString * path = [Tool getDownloadFilePathWithName:file.filePath];
        if( [fileManager fileExistsAtPath:path] )
        {
            [fileManager removeItemAtPath:path error:nil];
        }
        
        // 删除downloadArray中对应的元素 更新downloadArray.xml文件的内容
        [self.fileList removeObjectAtIndex: indexPath.row];
        NSMutableData * data = [NSMutableData new];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:self.fileList forKey:@"downloadArray"];
        [archiver finishEncoding];
        [data writeToFile:[Tool getDownloadArrayPath] atomically:YES];
        
        // 删除列表视图对应的行
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSLog(@"[%@ tableView:commitEditingStyle:forRowAtIndexPath: end......]",self.class);

}

- (void) tableView :(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"[%@ tableView:didSelectRowAtIndexPath: start......]",self.class);
    
    
    File * file = [self.fileList objectAtIndex:indexPath.row];
    if(![file isVerificated])
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"This file is not verificated".localizedString message:@"please select other file".localizedString delegate:nil cancelButtonTitle:@"OK ,I know!".localizedString otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if(self.state == 0)
    {
        FileShowViewController * controller = [[FileShowViewController alloc] init];
        
        [controller setFile: file];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        [self.delegate handleSelectFile:file withController:self];
    }
    
    
    NSLog(@"[%@ tableView:didSelectRowAtIndexPath: end......]",self.class);

}

@end
