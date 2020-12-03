//
//  CZFilterMenuHelper.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterMenuHelper.h"

@implementation CZFilterMenuHelper
/// 获取上下箭头
/// @param front 区分上下箭头
+ (UIImage *)drawTriangleWithFront:(BOOL)front color:(UIColor *)color {
    CGFloat w = 7;
    CGFloat h = 4;
    
    UIView *triangleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    
    CAShapeLayer *triangleLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (front) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(w, 0)];
        [path addLineToPoint:CGPointMake(w * 0.5, h)];
        triangleLayer.path = path.CGPath;
        [triangleView.layer addSublayer:triangleLayer];
        [triangleLayer setFillColor:color.CGColor];
    }else {
        [path moveToPoint:CGPointMake(w * 0.5, 0)];
        [path addLineToPoint:CGPointMake(0, h)];
        [path addLineToPoint:CGPointMake(w, h)];
        triangleLayer.path = path.CGPath;
        [triangleView.layer addSublayer:triangleLayer];
        [triangleLayer setFillColor:color.CGColor];
    }
    
    triangleView.backgroundColor = [UIColor whiteColor];
    UIGraphicsBeginImageContextWithOptions(triangleView.frame.size, YES, [UIScreen mainScreen].scale);  //图形上下文设置
    [triangleView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//赋值
    UIGraphicsEndImageContext();//结束
    return image;
}

/**
 更改button图片文本位置
 type:1~文本在左，图片在右；2~图片在上，文本在下
 */
+ (void)layoutButtonWithButton:(UIButton *)button
               imageTitleSpace:(CGFloat)space {

    CGFloat imageWith = button.imageView.frame.size.width;
    CGFloat labelWidth = button.titleLabel.intrinsicContentSize.width;

    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
    labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
    
    // 4. 赋值
    button.titleEdgeInsets = labelEdgeInsets;
    button.imageEdgeInsets = imageEdgeInsets;
}


+ (NSBundle *)libBundle {
    NSString *bundlePath = [[NSBundle bundleForClass:self.class].resourcePath stringByAppendingPathComponent:@"CZFilterMenuResource.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    // 这句代码可能会引起闪退,暂时没想到好的解决
    if (bundle == nil) {
        bundle = [NSBundle bundleForClass:self.class];
    }
    return bundle;
}
@end
