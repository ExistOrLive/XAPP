//
//  PhotoOperation.m
//  NavigationControllerDemo
//
//  Created by panzhengwei on 2017/8/29.
//  Copyright © 2017年 zhumeng. All rights reserved.
//

#import "PhotoOperation.h"


@implementation PhotoOperation

+(void)imageFromAssetURL:(NSURL *)url success:(void(^)(UIImage *))successblock{
    

    
    ALAssetsLibrary* lib=[[ALAssetsLibrary alloc]init];
    
    [lib assetForURL:url resultBlock:^(ALAsset *asset){
        UIImage * image;
        ALAssetRepresentation *assetRep=[asset defaultRepresentation];
        CGImageRef imgRef=[assetRep fullResolutionImage];
        image=[UIImage imageWithCGImage:imgRef scale:assetRep.scale orientation:(UIImageOrientation)assetRep.orientation];
        
        if(nil!=image){
             NSLog(@"%@",@"photo failed");
        }
        successblock(image);
        
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    
 
    
    
}




@end
