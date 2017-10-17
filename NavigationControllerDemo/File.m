
//
//  File.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "File.h"

@implementation File


-(NSString *)description
{
    NSString * result = @"NULL";
    
    if([self isImage])
    {
        if([self fileData])
        {
            result = [NSString stringWithFormat:@"md5 = %@, type = %@, length = %lld", self.md5,self.fileType,self.length];
        }
    }
    else
    {
        if([self fileData])
        {
            result = [NSString stringWithFormat:@"md5 = %@, type = %@, length = %lld, path = %@", self.md5,self.fileType,self.length,self.filePath];
        }
    }
    
    return result;
}

-(id) copyWithZone:(NSZone *)zone
{
    File * copy = [[[self class] allocWithZone:zone] init];
    
    copy.filePath = [self.filePath copy];
    copy.fileURL = [self.fileURL copy];
    copy.md5 = [self.md5 copy];
    copy.fileType = [self.fileType copy];
    copy.length = self.length;
    copy.currentLength = self.currentLength;
    copy.isVerificated = self.isVerificated;
    copy.isImage =self.isImage;
    copy.fileData = [self.fileData copy];
    
    return copy;
}


-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if(self =[super init]){
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
        self.fileURL = [aDecoder decodeObjectForKey:@"fileURL"];
        self.md5 = [aDecoder decodeObjectForKey:@"md5"];
        self.fileType = [aDecoder decodeObjectForKey:@"fileType"];
        self.length = [aDecoder decodeInt64ForKey:@"length"];
        self.currentLength = [aDecoder decodeInt64ForKey:@"currentLength"];
        self.isImage = [aDecoder decodeBoolForKey:@"isImage"];
        self.isVerificated = [aDecoder decodeBoolForKey:@"isVertificated"];
        self.fileData = [aDecoder decodeObjectForKey:@"fileData"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.filePath forKey:@"filePath"];
    [coder encodeObject:self.md5 forKey:@"md5"];
    [coder encodeObject:self.fileType forKey:@"fileType"];
    [coder encodeInt64:self.length forKey:@"length"];
    [coder encodeInt64:self.currentLength forKey:@"currentLength"];
    [coder encodeBool:self.isImage forKey:@"isImage"];
    [coder encodeBool:self.isVerificated forKey:@"isVertificated"];
    [coder encodeObject:self.fileData forKey:@"fileData"];
    [coder encodeObject:self.fileURL forKey:@"fileURL"];
}

/**
 @description 检查文件一致性，即检查file实例指向的文件的md5值与file.md5是否一致
 **/
-(bool) checkConsistency;
{
    if(!self.filePath)
        
        return false;
    
    NSString * absoluteFilePath = [Tool getDownloadFilePathWithName:self.filePath];
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:absoluteFilePath];
    NSString * currentMd5 = [MD5 md5EncodeFromFileHandle:fileHandle];
    
    NSLog(@"[%s [%d]] : md5 : %@ currentMd5 :%@",__func__,__LINE__,self.md5,currentMd5);
    
    if([self.md5 isEqualToString:currentMd5])
        return true;
    else
        return false;
}


@end
