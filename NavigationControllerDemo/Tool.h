//
//  Tool.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/31.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject

+ (NSString *) getDownloadArrayPath;

+ (NSString *) getDownloadFilePathWithName:(NSString *)name;

@end
