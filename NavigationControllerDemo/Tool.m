
//
//  Tool.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/31.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "Tool.h"

@implementation Tool

+ (NSString *) getDownloadArrayPath
{
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * downloadArrayPath = [docPath stringByAppendingPathComponent:@"/downloadArray.xml"];
    return downloadArrayPath;
}

+(NSString *) getDownloadFilePathWithName:(NSString *)name{
    
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * downloadFilePath = [docPath stringByAppendingPathComponent:name];
    
    /*
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:downloadFilePath isDirectory:false])
    {
        [fileManager removeItemAtPath:downloadFilePath error:nil];
    }
     */
    
    return downloadFilePath;
    
}

@end
