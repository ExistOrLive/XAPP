//
//  PhotoOperation.h
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoOperation : NSObject


+(void)imageFromAssetURL:(NSURL *)url success:(void(^)(UIImage *))successblock;

@end
