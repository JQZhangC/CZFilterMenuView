//
//  CZFilterMenuHelper.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZFilterMenuHelper : NSObject

/// 获取上下箭头
/// @param front 区分上下箭头
+ (UIImage *)drawTriangleWithFront:(BOOL)front color:(UIColor *)color;

/**
 更改button图片文本位置
 type:1~文本在左，图片在右；2~图片在上，文本在下
 */
+ (void)layoutButtonWithButton:(UIButton *)button
               imageTitleSpace:(CGFloat)space;
@end

NS_ASSUME_NONNULL_END
