//
//  ScanView.m
//  MOA
//
//  Created by 郑冰津 on 16/7/1.
//  Copyright © 2016年 zte. All rights reserved.
//

#import "ScanView.h"

#define scanWidth (SCREEN_WIDTH-100)

#define transparentDarkGray [UIColor colorWithWhite:0 alpha:.5]

#define SCREENBOUNDS [UIScreen mainScreen].bounds
#define SCANSPACEOFFSET 0.1f

@interface ScanView()

@property (nonatomic,strong)CAShapeLayer * maskLayer;
@property (nonatomic,strong)CAShapeLayer * shadowLayer;
@property (nonatomic,strong)CAShapeLayer * scanRectLayer;

@property (nonatomic,assign)CGRect scanRect;
//计算用
@property (nonatomic,assign)CGRect outputRect;
@property (nonatomic,assign)CGRect topFrame;
@property (nonatomic,assign)CGRect bottomFrame;


@end

@implementation ScanView{
    BOOL isStartAnimationing;///是否正在播放动画
    BOOL isDidStop;///是否停止了动画!
    UIImageView * imageView;
    CGFloat ScreenWidth;
    CGFloat ScreenHeight;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    UIScreen * screen = [UIScreen mainScreen];
    ScreenWidth = [screen bounds].size.width;
    ScreenHeight = [screen bounds].size.height;
    
    if (self) {
        ///镂空操作
        CGFloat size = ScreenWidth *(1- 2*SCANSPACEOFFSET);
        CGFloat minY = (ScreenHeight-64 - size)*0.5/ScreenHeight;
        CGFloat maxY =   (ScreenHeight -64+ size)*0.5/ScreenHeight;
        
        _outputRect = CGRectMake(minY, SCANSPACEOFFSET, maxY, 1-SCANSPACEOFFSET*2);
        
        //正方形，宽高为 屏幕宽度的0.8倍, [{{32, 124}, {256, 256}}]
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth-(ScreenWidth*(1-SCANSPACEOFFSET*2)))/2 , (ScreenHeight-64-(ScreenWidth*(1-SCANSPACEOFFSET*2)))/2, ScreenWidth*(1-SCANSPACEOFFSET*2), ScreenWidth*(1-SCANSPACEOFFSET*2))];
        
        //todo
        imageView.image = [UIImage imageNamed:@"Scan_Pick"];
        
        UILabel * remindLable = [[UILabel alloc]init];
        remindLable.font = [UIFont systemFontOfSize:15.0f];
        remindLable.textColor = [UIColor whiteColor];
        remindLable.numberOfLines = 0;
        
        //todo
        NSString * remindText = @"Align the QR Code within the frame to scan".localizedString;
        
        remindLable.text = remindText;
        remindLable.textAlignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
        
        CGSize remindSize = [remindText boundingRectWithSize:CGSizeMake(ScreenWidth-20, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
        remindLable.frame = CGRectMake(10, imageView.frame.size.height+imageView.frame.origin.y+20, ScreenWidth-20, remindSize.height);
    
        [self addSubview:remindLable];
        [self addSubview:imageView];
        [self.layer addSublayer:self.shadowLayer];
     
    }
    return self;
}
#pragma mark -- 点击我的二维码按钮
-(void)myQRCodeButtonClicked:(UIButton *)button
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(myQRCodeButtonClicked)])
    {
        [self.delegate myQRCodeButtonClicked];
    }
}

-(void) computeLineFrame
{
    CGRect frame = imageView.frame;
    frame.origin.x += 10;
    frame.size.width -= 20;
    frame.size.height = 2;
    
    _topFrame = frame;
    
    frame.origin.y += imageView.frame.size.height - 2;
    _bottomFrame = frame;
    
    NSLog(@"topFrame[%@] bottomFrame[%@]", NSStringFromCGRect(_topFrame), NSStringFromCGRect(_bottomFrame));
}

///动画开启
- (void)startAnimation
{
    if (isDidStop)
    {
        isDidStop=NO;
        [self animationLine];///再次开始动画
    }
    else
    {
        if (!isStartAnimationing)
        {
            [self animationLine];///第一次开始
        }
    }
}
///动画停止
- (void)stopAnimation
{
    isDidStop=YES;
    UIImageView *lineAnimation = (UIImageView *)[self viewWithTag:566];
    [lineAnimation removeFromSuperview];
}

- (void)animationLine
{
    if (isDidStop)
    {
        return;
    }

    UIImageView *lineAnimation = (UIImageView *)[self viewWithTag:566];
    if (!lineAnimation)
    {
        ///做动画的线
        [self computeLineFrame];
        
        lineAnimation = [[UIImageView alloc] initWithFrame:_topFrame];
        lineAnimation.tag = 566;
        [self addSubview:lineAnimation];
        lineAnimation.image = [UIImage imageNamed:@"Scan_PickLine"];
    }
    
    if (CGRectEqualToRect(lineAnimation.frame, _bottomFrame))
    {
        isStartAnimationing = YES;
        [UIView animateWithDuration:3 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            lineAnimation.frame = _topFrame;
        } completion:^(BOOL finished) {
            if (isDidStop)
            {
                lineAnimation.frame = _topFrame;
            }
            if (finished) {
                isStartAnimationing = NO;
                [self animationLine];
            }
        }];
    }
    else if (CGRectEqualToRect(lineAnimation.frame, _topFrame))
    {
        isStartAnimationing = YES;
        [UIView animateWithDuration:3 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            lineAnimation.frame = _bottomFrame;
        }
        completion:^(BOOL finished)
        {
            if (isDidStop)
            {
                lineAnimation.frame = _topFrame;
            }
            if (finished)
            {
                isStartAnimationing = NO;
                [self animationLine];
            }
        }];
    }
}

- (CGRect)scanRect
{
    if (CGRectEqualToRect(_scanRect, CGRectZero)) {
        CGRect rectOfInterest = _outputRect;
        CGFloat yOffset = rectOfInterest.size.width - rectOfInterest.origin.x;
        CGFloat xOffset = 1 - 2 * SCANSPACEOFFSET;
        _scanRect = CGRectMake(rectOfInterest.origin.y * ScreenWidth, rectOfInterest.origin.x * ScreenHeight, xOffset * ScreenWidth, yOffset * ScreenHeight);
    }
    return _scanRect;
}

- (CAShapeLayer *)maskLayer{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer = [self generateMaskLayerWithRect:SCREENBOUNDS exceptRect:self.scanRect];
    }
    return _maskLayer;
}

- (CAShapeLayer*)shadowLayer{
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        _shadowLayer.fillColor = [UIColor colorWithWhite:0 alpha:.5].CGColor;
        _shadowLayer.mask = self.maskLayer;
        
    }
    return _shadowLayer;
}

//- (UIImageView *)scanBgImageView{
//    if (!_scanBgImageView) {
//        _scanBgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
//        _scanBgImageView.image = [UIImage imageNamed:@"Scan_Bg"];
//        _scanBgImageView.layer.mask = self.maskLayer;
//    }
//    return _scanBgImageView;
//}

- (CAShapeLayer *)generateMaskLayerWithRect: (CGRect)rect exceptRect: (CGRect)exceptRect
{
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    if (!CGRectContainsRect(rect, exceptRect)) {
        return nil;
    }
    else if (CGRectEqualToRect(rect, CGRectZero)) {
        maskLayer.path = [UIBezierPath bezierPathWithRect: rect].CGPath;
        return maskLayer;
    }
    
    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);
    
    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    
    /** 添加路径*/
    UIBezierPath * path = [UIBezierPath bezierPathWithRect: CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

@end
