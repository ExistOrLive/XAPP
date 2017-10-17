//
//  AES.h
//  AESDemo
//
//  Created by panzhengwei on 2017/9/22.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES : NSObject

+(NSData *)AES256ParmEncryptWithKey:(NSString *)key Encrypttext:(NSData *)text;

+ (NSData *)AES256ParmDecryptWithKey:(NSString *)key Decrypttext:(NSData *)text;

// 对字符串加密
+(NSString *) aes256_encrypt:(NSString *)key Encrypttext:(NSString *)text;

// 对字符串解密
+(NSString *) aes256_decrypt:(NSString *)key Decrypttext:(NSString *)text;
@end
