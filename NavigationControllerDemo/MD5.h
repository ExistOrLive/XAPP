//
//  MD5.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/9/7.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

@interface MD5 : NSObject

+ (NSString *)md5EncodeFromData:(NSData *)data;

+ (NSString *)md5EncodeFromFileHandle:(NSFileHandle *)fileHandle;

@end
