//
//  ScanView.h
//  MOA
//
//  Created by 郑冰津 on 16/7/1.
//  Copyright © 2016年 zte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+localized.h"

@protocol MyQRCodeButtonClickedDelegate <NSObject>

@optional

- (void)myQRCodeButtonClicked;

@end

///扫描二维码的UI布局
@interface ScanView : UIView
@property (nonatomic,assign)id<MyQRCodeButtonClickedDelegate>delegate;
///初始化
- (instancetype)initWithFrame:(CGRect)frame;
///动画开启
- (void)startAnimation;
///动画停止
- (void)stopAnimation;

@end
