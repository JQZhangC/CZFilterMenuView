//
//  CZFilterMenuView.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZFilterMenuAppearance.h"
#import "CZFilterIndexPath.h"

/** 下拉展示类型 */
typedef NS_ENUM(NSUInteger, CZFilterMenuDownType) {
    CZFilterMenuDownTypeList,      // 以tableView展示
    CZFilterMenuDownTypeItem       // 以collectionView展示
};

/** 确定类型 */
typedef NS_ENUM(NSUInteger, CZFilterMenuConfirmType) {
    CZFilterMenuConfirmTypeSpeedConfirm,        // 点击列表确定选中返回
    CZFilterMenuConfirmTypeBottomConfirm        // 点击底部确定按钮选中返回
};


NS_ASSUME_NONNULL_BEGIN
@class CZFilterMenuView;

@protocol CZFilterMenuViewDetaSource <NSObject>

/// 返回 tap 数
- (NSInteger)numberOfTabInMenuView:(CZFilterMenuView *)menuView;

- (NSString *)menuView:(CZFilterMenuView *)menuView titleAtTabIndex:(NSInteger)tabIndex;

@optional

- (CZFilterMenuDownType)menuView:(CZFilterMenuView *)menuView typeAtTabIndex:(NSInteger)tabIndex;

- (CZFilterMenuConfirmType)menuView:(CZFilterMenuView *)menuView confirmTypeAtTabIndex:(NSInteger)tabIndex;


/// 返回每一列中的行数, 一级列表行数
/// @param menuView menuView
/// @param tab 列数
- (NSInteger)menuView:(CZFilterMenuView *)menuView numberOfFRowsInTab:(NSInteger)tab;

/// 返回二级列表行数
/// @param menuView menuView
/// @param fRow 一级列表 index
/// @param tab 列数
- (NSInteger)menuView:(CZFilterMenuView *)menuView numberOfSRowsInFRow:(NSInteger)fRow tab:(NSInteger)tab;

/// 返回三级列表行数
/// @param menuView menuView
/// @param sRow 二级列表 index
/// @param fRow 一级列表 index
/// @param tab 列数
- (NSInteger)menuView:(CZFilterMenuView *)menuView numberOfTRowsInSRow:(NSInteger)sRow fRow:(NSInteger)fRow tab:(NSInteger)tab;

/// 展示的标题
/// @param menuView menuView
/// @param indexPath 第一列
- (NSString *)menuView:(CZFilterMenuView *)menuView titleForFRowsAtIndexPath:(CZFilterIndexPath *)indexPath;

/// 展示的标题
/// @param menuView menuView
/// @param indexPath 第二列
- (NSString *)menuView:(CZFilterMenuView *)menuView titleForSRowsAtIndexPath:(CZFilterIndexPath *)indexPath;

/// 展示的标题
/// @param menuView menuView
/// @param indexPath 第三列, list类型独有
- (NSString *)menuView:(CZFilterMenuView *)menuView titleForTRowsAtIndexPath:(CZFilterIndexPath *)indexPath;

/// 是否允许多选
/// @param menuView menuView
/// @param indexPath indexPath, 目前仅支持item类型
- (BOOL)menuView:(CZFilterMenuView *)menuView mutiSelectedAtIndexPath:(CZFilterIndexPath *)indexPath;

- (CGFloat)menuView:(CZFilterMenuView *)menuView heightForFooterAtIndexPath:(CZFilterIndexPath *)indexPath;

/// 返回占位文字及单位,数组长度必须为3,前2位是占位文字,第3位是单位
/// @param menuView menuView
/// @param indexPath menuView
- (NSArray<NSString *> *)menuView:(CZFilterMenuView *)menuView placeholdersAtIndexPath:(CZFilterIndexPath *)indexPath;

@end

@protocol CZFilterMenuViewDelegate <NSObject>

@optional

/// 点击tab之后调用
- (void)menuView:(CZFilterMenuView *)menuView didTapMenuAtTabIndex:(NSUInteger)tabIndex;

/// 点击列表之后调用
- (void)menuView:(CZFilterMenuView *)menuView didSelectedMenuAtIndexPath:(CZFilterIndexPath *)indexPath;

///// 取消tab对应的筛选条件,item 模式且fRow数量 等于1时有效
- (void)menuView:(CZFilterMenuView *)menuView clearFilterConditionAtTabIndex:(NSInteger)tabIndex;

/// item类型带有输入模式
/// @param menuView menuView
/// @param inputTexts 输入的文字,字符串数组形式,长度2
/// @param indexPath indexPath
- (void)menuView:(CZFilterMenuView *)menuView inputTexts:(NSArray<NSString *> *)inputTexts indexPath:(CZFilterIndexPath *)indexPath;

- (void)menuView:(CZFilterMenuView *)menuView inputTextsFailureAtIndexPath:(CZFilterIndexPath *)indexPath;
@end

@interface CZFilterMenuView : UIView

@property (nonatomic, weak) id<CZFilterMenuViewDetaSource> cz_dataSource;

@property (nonatomic, weak) id<CZFilterMenuViewDelegate> cz_delegate;

@property (nonatomic, strong, readonly) CZFilterMenuAppearance *appearance;
/// 下拉菜单是否正在展示
@property (nonatomic, assign, readonly) BOOL showInWindow;
/// 下拉框菜单 展示 延迟时间, 仅showInWindow = YES 时有效
@property (nonatomic, assign) NSTimeInterval showDelay;

- (instancetype)initWithFrame:(CGRect)frame
                appearance:(CZFilterMenuAppearance *)appearance;

- (void)reloadMenuView;
@end

NS_ASSUME_NONNULL_END
