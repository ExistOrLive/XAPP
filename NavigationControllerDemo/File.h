//
//  File.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MD5.h"
#import "Tool.h"

@interface File : NSObject <NSCopying,NSCoding>

// file的文件存储路径
@property(strong) NSString * filePath;

// file的文件路径的URL
@property(strong) NSURL * fileURL;

//file文件的md5值
@property(strong) NSString * md5;

//file文件的类型
@property(strong) NSString * fileType;

//file文件的长度
@property unsigned long long length;

// file存储路径下的文件的实际长度
@property unsigned long long currentLength;

// file文件是否被验证过（md5校验）
@property bool isVerificated;

// file是否为图片
@property bool isImage;

//
@property(strong) NSData * fileData;

// 指向file存储路径下文件的NSFileHandle实例
@property (strong) NSFileHandle * fileHandle;




/**
 @description 检查文件一致性，即检查file实例指向的文件的md5值与file.md5是否一致
 **/
-(bool) checkConsistency;

@end
