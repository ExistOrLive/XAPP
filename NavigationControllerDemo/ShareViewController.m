//
//  ShareViewController.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "ShareViewController.h"


@interface ShareViewController ()
{
    bool isAlbum;
}

-(void) selectAlbum;

-(void) selectLocalFile;

@end


@implementation ShareViewController

- (void)viewDidLoad {

    NSLog(@"[%s [%d]]: start......",__func__,__LINE__);
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"share".localizedString;
    [self.selectButton setTitle:@"album".localizedString forState:UIControlStateNormal];
    [self.reselectButton setTitle:@"reselect".localizedString forState:UIControlStateNormal];
    [self.localFileButton setTitle:@"local file".localizedString forState:UIControlStateNormal];
    [self.shareButton setTitle:@"share".localizedString forState:UIControlStateNormal];
    
    
    if(![self.imageView image]){
        [self.selectButton setHidden:NO];
        [self.localFileButton setHidden:NO];
        [self.reselectButton setHidden:YES];
        [self.shareButton setHidden:YES];
    }else{
        [self.selectButton setHidden:YES];
        [self.localFileButton setHidden:YES];
        [self.reselectButton setHidden:NO];
        [self.shareButton setHidden:NO];
    }
    
    NSLog(@"[%s [%d]]: end......",__func__,__LINE__);

}



/**
 album , localFile , reselect button的操作方法
 **/
- (IBAction)reselectClicked:(id)sender {
   
    if(self.selectButton == sender)
    {
        isAlbum = YES;
        [self selectAlbum];
    }
    else if(self.localFileButton == sender)
    {
        isAlbum = NO;
        [self selectLocalFile];
    }
    else
    {
        if(isAlbum)
            [self selectAlbum];
        else
            [self selectLocalFile];
    }

}

/**
  shareButton的操作方法
 **/

- (IBAction)shareClicked:(id)sender {
    
    NSLog(@"[%@ shareClicked start......]",self.class);
    
    
    
//    NSString * ipCurrent = [Network getIPAddress:YES];
//    if(![ip isEqualToString:ipCurrent])
//    {
//        NSLog(@"[%@ shareClicked ] : the extern ip is different from current ip ",self.class);
//        
//        
//        [connectionServer close];
//        connectionServer = [[ConnectionServer alloc] initWithPort:port];
//        
//        if(!connectionServer)
//        {
//            NSLog(@"[%@ shareClicked ]: connectionServer rebuild failed!!!!!!",self.class);
//        }
//        else
//        {
//            NSLog(@"[%@ shareClicked] : connectionServer rebuild success!!!!!!",self.class);
//            ip = ipCurrent;
//            port = [connectionServer port];
//        }
//        
//        [connectionServer acceptAndHandleConnection];
//        
//        NSLog(@"[%@ shareClicked] : connectionServer start accept!!!!!!",self.class);
//    }
    
    extern int port;
    extern NSString * ip;
    extern ConnectionServer * connectionServer;
    
    
    // 1.如果未连接网络，则发出警告，并返回
    if([ip isEqualToString:@"0.0.0.0"] || ip == nil)
    {
        UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"the iphone is not connected to network" message:@"please the network"preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
   
    
    
    // 2. 如果连接网络，则生成二维码，并切换至二维码显示界面
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:ip forKey:@"ip"];
    [dic setObject:[NSString stringWithFormat:@"%d",port] forKey:@"port"];
    NSDate * date = [[NSDate alloc] init];
    double time = [date timeIntervalSince1970];
    NSString * key = [NSString stringWithFormat:@"%f",time];
    [dic setObject:key forKey:@"key"];
    
    NSString * qrcodeStr = [Network packageMessage:dic];
    UIImage * qrcodeImage = [QRCodeTool qrImageForString:qrcodeStr imageSize:1000.0 logoImageSize:100.0];
    if(!qrcodeImage)
    {
        NSLog(@"[%@ sharedClicked] : the qrcodeImage create failed",self.class);
        UIAlertController * alertController=[UIAlertController alertControllerWithTitle:@"the qrcodeImage create failed,please try again" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action=[UIAlertAction actionWithTitle:@"OK, I know!" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
   
        QRCodeViewController * controller = [[QRCodeViewController alloc] init];
        [controller setQrImage:qrcodeImage];
        [connectionServer setKey:key];
        [connectionServer setIsSharing:YES];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    
    /*
    ShareProcessViewController * controller  = [[ShareProcessViewController alloc]init];
    [controller setData:data];
    [self.navigationController pushViewController:controller animated:YES];
     */
    
     NSLog(@"[%@ shareClicked end......]",self.class);
 
  
}



/**
 选择相册分享
 **/
- (void) selectAlbum
{
    NSLog(@"[%s [%d]] : start......", __func__,__LINE__);
    
    UIImagePickerController *  imageController=[[UIImagePickerController alloc]init];
    imageController.delegate=self;
    imageController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    NSArray * typeArray = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
    imageController.mediaTypes = typeArray;
    
    [self presentViewController:imageController animated:YES completion:nil];
    
    NSLog(@"[%s [%d]] : end......", __func__,__LINE__);
}


/**
 选择本地文件分享
 **/
- (void) selectLocalFile
{
    NSLog(@"[%s [%d]] : start......", __func__,__LINE__);
    
    FileListTableViewController * controller = [[FileListTableViewController alloc] init];
    [controller setDelegate:self];
    [controller setState:1];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    NSLog(@"[%s [%d]] : end......", __func__,__LINE__);
    
}

/**
 选择本地文件的回调方法
 @prama seletedFile   选择用于分享的文件
 @prama controller    选择本地文件的viewController
 **/
-(void) handleSelectFile:(File *)selectedFile withController:(id)controller
{
    NSLog(@"[%s [%d]] : start......", __func__,__LINE__);
    
    extern File * file;
    file = selectedFile;
    NSString * path = [Tool getDownloadFilePathWithName:file.filePath];
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:path];
    file.fileHandle = handle;
    
    NSLog(@"[%s [%d]] : file info = %@", __func__,__LINE__,file);

    UIImage * selectedImage = [[UIImage alloc] initWithContentsOfFile:path];
    [self.imageView setImage:selectedImage];
    [self.selectButton setHidden:YES];
    [self.localFileButton setHidden:YES];
    [self.reselectButton setHidden:NO];
    [self.shareButton setHidden:NO];
    
    [self.navigationController popViewControllerAnimated:YES];

    NSLog(@"[%s [%d]] : end......", __func__,__LINE__);
    
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSLog(@"[%@ imagePickerController:didFinishPickingMediaWithInfo] : start......", [self class]);
    
    extern File * file;
    file = [[File alloc] init];
    
    NSString * type = info[UIImagePickerControllerMediaType];
    
    if([type isEqualToString:@"public.image"])
    {
        UIImage * selectedImage = info[UIImagePickerControllerOriginalImage];
        NSData * data = UIImagePNGRepresentation(selectedImage);
        NSString * path =[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.png"];
        [data writeToFile:path atomically:YES];
        
        NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        unsigned long long length = [fileHandle seekToEndOfFile];
        [fileHandle seekToFileOffset:0];
        NSString * md5 = [MD5 md5EncodeFromFileHandle:fileHandle];
        [fileHandle seekToFileOffset:0];
        
        [file setMd5:md5];
        [file setFileType:@"png"];
        [file setLength: length];
        [file setIsImage:YES];
        [file setFileHandle:fileHandle];
        
        NSLog(@"[%@ imagePickerController:didFinishPickingMediaWithInfo] : file info : %@", [self class],file);
        
        [self.imageView setImage:selectedImage];
        [self.selectButton setHidden:YES];
        [self.localFileButton setHidden:YES];
        [self.reselectButton setHidden:NO];
        [self.shareButton setHidden:NO];
        
    }
    else if([type isEqualToString:@"public.movie"])
    {
        NSURL * mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingFromURL:mediaURL error:nil];
        unsigned long long length = [fileHandle seekToEndOfFile];
        [fileHandle seekToFileOffset:0];
        NSString * md5 = [MD5 md5EncodeFromFileHandle:fileHandle];
        [fileHandle seekToFileOffset:0];
        [file setMd5:md5];
        [file setFileType:@"mov"];
        [file setLength: length];
        [file setIsImage:NO];
        [file setFileHandle:fileHandle];
        
        NSLog(@"[%@ imagePickerController:didFinishPickingMediaWithInfo] : file info : %@", [self class],file);
        
        [self.imageView setImage:[UIImage imageNamed:@"icon.png"]];
        [self.selectButton setHidden:YES];
        [self.localFileButton setHidden:YES];
        [self.reselectButton setHidden:NO];
        [self.shareButton setHidden:NO];
    
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"[%@ imagePickerController:didFinishPickingMediaWithInfo] : end......", [self class]);
    
}

@end
