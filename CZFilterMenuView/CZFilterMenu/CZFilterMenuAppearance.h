//
//  CZFilterMenuAppearance.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZFilterMenuAppearance : NSObject
/** 内间距, 默认(0.0, 10.0, 0.0, 10.0) */
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
/** 按钮间距, 默认值5 */
@property (nonatomic, assign) CGFloat padding;
/** 文字默认颜色, 默认black color */
@property (nonatomic, strong) UIColor *textColor;
/** 文字选中颜色, 默认red color*/
@property (nonatomic, strong) UIColor *tintColor;
/** 背景颜色, 默认 lightGrayColor */
@property (nonatomic, strong) UIColor *backgroundColor;
/** 选中背景颜色, 默认 white */
@property (nonatomic, strong) UIColor *backgroundTintColor;

/** title 字体大小, 默认15 */
@property (nonatomic, assign) CGFloat titleFontSize;
/** cell 字体大小, 默认15 */
@property (nonatomic, assign) CGFloat cellFontSize;

/** item类型 header 字体大小, 默认20 */
@property (nonatomic, assign) CGFloat itemHeaderFontSize;
/** item类型 cell 字体大小, 默认13 */
@property (nonatomic, assign) CGFloat itemCellFontSize;

/** 默认图片, 默认倒三角,black color */
@property (nonatomic, strong) UIImage *normalImage;
/** 点击tab图片, 默认正三角, tintColor */
@property (nonatomic, strong) UIImage *selectedImage;
/** 存在选中样式图片, 默认图片, 默认倒三角, tintColor */
@property (nonatomic, strong) UIImage *tintNormalImage;

@property (nonatomic, assign) CGFloat cutomFirstTableViewWidthWhenMuti;

@property (nonatomic, assign) CGFloat cutomSecondTableViewWidthWhenMuti;
@end

NS_ASSUME_NONNULL_END
