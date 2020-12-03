//
//  CZFilterMenuView.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterMenuView.h"
#import "CZFilterMenuHelper.h"
#import "CZFilterMenuTableViewCell.h"
#import "CZFilterButton.h"
#import "CZBottomConfirmView.h"
#import "CZFilterMenuCollectionViewCell.h"
#import "CZFilterMenuCollectionHeaderView.h"
#import "CZFilterMenuCollectionFooterInputView.h"

/** list 下拉展示类型 */
typedef NS_ENUM(NSUInteger, CZFilterMenuListType) {
    CZFilterMenuListTypeSingle,         // 以单一tableView展示
    CZFilterMenuListTypeDouble,         // 以双tableView展示
    CZFilterMenuListTypeTriple,         // 以三tableView展示
    CZFilterMenuListTypeUnKnow         // 未知布局类型
};

@interface CZFilterMenuView () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    struct {
        unsigned int typeAtTabIndex : 1;
        unsigned int titleAtTabIndex : 1;
        unsigned int numberOfFRowsInTab : 1;
        unsigned int numberOfSRowsInFRow : 1;
        unsigned int numberOfTRowsInSRow : 1;
        unsigned int numberOfTabInMenuView : 1;
        unsigned int confirmTypeAtTabIndex : 1;
        unsigned int mutiSelectedAtIndexPath : 1;
        unsigned int titleForFRowsAtIndexPath : 1;
        unsigned int titleForSRowsAtIndexPath : 1;
        unsigned int titleForTRowsAtIndexPath : 1;
        unsigned int placeholdersAtIndexPath: 1;
        unsigned int heightForFooterAtIndexPath: 1;
        unsigned int inputTexts: 1;
        
        unsigned int didTapMenuAtTabIndex : 1;
        unsigned int didSelectedMenuAtIndexPath : 1;
        unsigned int inputTextsFailureAtIndexPath: 1;
        unsigned int clearFilterConditionAtTabIndex : 1;
        
        
    } _dataSourceFlags;
}

/** 下拉菜单样式 */
@property (nonatomic, strong, readwrite) CZFilterMenuAppearance *appearance;
/// 下拉菜单是否正在展示
@property (nonatomic, assign, readwrite) BOOL showInWindow;

/** 记录当前选中的tab */
@property (nonatomic, assign) NSInteger selectedTabIndex;
/** 记录选中的indexPath */
@property (nonatomic, strong) NSMutableArray<NSSet *> *selectedIndexPaths;
/** 最终返回的选中结果 */
@property (nonatomic, strong) NSMutableArray<NSSet *> *resultSelectedIndexPaths;
/** 输入的文字 */
@property (nonatomic, strong) NSMutableDictionary *inputTexts;
/** 最终返回的输入的文字 */
@property (nonatomic, strong) NSMutableDictionary *resultInputTexts;
/** 记录当前选中的tab */
@property (nonatomic, strong) NSArray<CZFilterButton *> *tabButtons;
/** 蒙版视图 */
@property (nonatomic, strong) UIView *maskView;
/** 筛选tableView\collcetionView的容器视图 */
@property (nonatomic, strong) UIView *filerContainerView;
/** 下拉筛选条件,确定及重置视图 */
@property (nonatomic, strong) CZBottomConfirmView *confirmView;
/** tableView视图 */
@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *centerTableView;
@property (nonatomic, strong) UITableView *rightTableView;
/** collectionView视图 */
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat adjustOffsetY;
@end

static CGFloat const kTableViewRowHeight = 42;
static CGFloat const kCollectionSectioinHeaderHeight = 50;
static NSInteger const kCollectionNumberOfColumn = 4;
static CGFloat const kCollectionLineSpacing = 10;
static CGFloat const kCollectionItemHeight = 34;
static UIEdgeInsets const kCollectionContentInsets = {0.0, 20, 20.0, 20};
static NSString *const kTableViewCellId = @"CZFilterMenuTableViewCell";
static NSString *const kCollectionViewCellId = @"CZFilterMenuCollectionViewCell";
static NSString *const kCollectionViewHeaderId = @"CZFilterMenuCollectionHeaderView";
static NSString *const kCollectionViewFooterId = @"CZFilterMenuCollectionFooterInputView";

@implementation CZFilterMenuView

- (instancetype)initWithFrame:(CGRect)frame appearance:(CZFilterMenuAppearance *)appearance {
    if (self = [super initWithFrame:frame]) {
        _appearance = appearance;
        _selectedTabIndex = -1;
    }
    return self;
}

- (void)reloadMenuView {
    [self.tabButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self loadFilterNemuView];
}

#pragma mark - Private Method
- (void)loadFilterNemuView {
    
    if (self.cz_dataSource == nil) {
        return;
    }
    
    // 缓存方法响应
    _dataSourceFlags.numberOfTabInMenuView = [self.cz_dataSource respondsToSelector:@selector(numberOfTabInMenuView:)];
    _dataSourceFlags.titleAtTabIndex = [self.cz_dataSource respondsToSelector:@selector(menuView:titleAtTabIndex:)];
    _dataSourceFlags.typeAtTabIndex = [self.cz_dataSource respondsToSelector:@selector(menuView:typeAtTabIndex:)];
    _dataSourceFlags.confirmTypeAtTabIndex = [self.cz_dataSource respondsToSelector:@selector(menuView:confirmTypeAtTabIndex:)];
    _dataSourceFlags.numberOfFRowsInTab = [self.cz_dataSource respondsToSelector:@selector(menuView:numberOfFRowsInTab:)];
    _dataSourceFlags.numberOfSRowsInFRow = [self.cz_dataSource respondsToSelector:@selector(menuView:numberOfSRowsInFRow:tab:)];
    _dataSourceFlags.numberOfTRowsInSRow = [self.cz_dataSource respondsToSelector:@selector(menuView:numberOfTRowsInSRow:fRow:tab:)];
    _dataSourceFlags.mutiSelectedAtIndexPath = [self.cz_dataSource respondsToSelector:@selector(menuView:mutiSelectedAtIndexPath:)];
    _dataSourceFlags.titleForFRowsAtIndexPath = [self.cz_dataSource respondsToSelector:@selector(menuView:titleForFRowsAtIndexPath:)];
    _dataSourceFlags.titleForSRowsAtIndexPath = [self.cz_dataSource respondsToSelector:@selector(menuView:titleForSRowsAtIndexPath:)];
    _dataSourceFlags.titleForTRowsAtIndexPath = [self.cz_dataSource respondsToSelector:@selector(menuView:titleForTRowsAtIndexPath:)];
    _dataSourceFlags.placeholdersAtIndexPath = [self.cz_dataSource respondsToSelector:@selector(menuView:placeholdersAtIndexPath:)];
    _dataSourceFlags.heightForFooterAtIndexPath = [self.cz_dataSource respondsToSelector:@selector(menuView:heightForFooterAtIndexPath:)];
    
    _dataSourceFlags.inputTexts = [self.cz_delegate respondsToSelector:@selector(menuView:inputTexts:indexPath:)];
    _dataSourceFlags.didTapMenuAtTabIndex = [self.cz_delegate respondsToSelector:@selector(menuView:didTapMenuAtTabIndex:)];
    _dataSourceFlags.didSelectedMenuAtIndexPath = [self.cz_delegate respondsToSelector:@selector(menuView:didSelectedMenuAtIndexPath:)];
    _dataSourceFlags.inputTextsFailureAtIndexPath = [self.cz_delegate respondsToSelector:@selector(menuView:inputTextsFailureAtIndexPath:)];
    _dataSourceFlags.clearFilterConditionAtTabIndex = [self.cz_delegate respondsToSelector:@selector(menuView:clearFilterConditionAtTabIndex:)];
    
    
    // 获取tab数量
    NSInteger numberOfTab = 0;
    if (_dataSourceFlags.numberOfTabInMenuView) {
        numberOfTab = [self.cz_dataSource numberOfTabInMenuView:self];
    }
    
    if (numberOfTab == 0) { // = 0,则直接返回
        return;
    }
    
    // 获取样式
    CZFilterMenuAppearance *appearance = self.appearance;
    
    // 检查图片,如果没有则创建默认三角图片
    if (appearance.selectedImage == nil) {
        appearance.selectedImage = [[CZFilterMenuHelper drawTriangleWithFront:NO color:appearance.tintColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    if (appearance.tintNormalImage == nil) {
        appearance.tintNormalImage = [[CZFilterMenuHelper drawTriangleWithFront:YES color:appearance.tintColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    if (appearance.normalImage == nil) {
        appearance.normalImage = [[CZFilterMenuHelper drawTriangleWithFront:YES color:appearance.textColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    // 设置背景色
    self.backgroundColor = UIColor.whiteColor;
    
    // 提取图片
    UIImage *normalImage = appearance.normalImage;
    UIImage *selectedImage = appearance.selectedImage;
    
    // 计算tab按钮宽度
    CGFloat buttonWidth = (self.frame.size.width - (numberOfTab - 1) * appearance.padding - appearance.contentEdgeInsets.left - appearance.contentEdgeInsets.right) / numberOfTab;
    
    // 添加tab按钮
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (int i = 0; i < numberOfTab; i++) {
        CZFilterButton *button = [CZFilterButton buttonWithType:UIButtonTypeSystem];
        button.tintColor = [UIColor clearColor];
        button.adjustsImageWhenHighlighted = NO;
        button.backgroundColor = UIColor.whiteColor;
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [button addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitleColor:appearance.textColor forState:UIControlStateNormal];
        [button setTitleColor:appearance.tintColor forState:UIControlStateSelected];
        [button setTitleColor:appearance.tintColor
                     forState:UIControlStateHighlighted | UIControlStateSelected];
        
        [button setImage:normalImage forState:UIControlStateNormal];
        [button setImage:selectedImage forState:UIControlStateSelected];
        [button setImage:selectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
        
        
        if (_dataSourceFlags.titleAtTabIndex) {
            NSString *title = [self.cz_dataSource menuView:self titleAtTabIndex:i];
            [button setTitle:title forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:appearance.titleFontSize];
        
        // 设置frame
        CGFloat x = i * (buttonWidth + appearance.padding) + appearance.contentEdgeInsets.left;
        CGFloat y = appearance.contentEdgeInsets.top;
        CGFloat height = self.frame.size.height - appearance.contentEdgeInsets.top - appearance.contentEdgeInsets.bottom;
        button.frame = CGRectMake(x, y, buttonWidth, height);
        [self addSubview:button];
        [CZFilterMenuHelper layoutButtonWithButton:button imageTitleSpace:4.0];
        
        [buttons addObject:button];
    }
    
    self.tabButtons = [buttons copy];
}

#pragma mark - <-----------------  list类型 和 item类型 共用方法  ----------------->
#pragma mark - tab 点击操作
- (void)menuTapped:(CZFilterButton *)button {
    if (self.cz_dataSource == nil) {
        return;
    }
    
    // 修改上一个选中的按钮状态
    if (self.selectedTabIndex >= 0) {
        [self updateMenuTitleAtTabIndex:self.selectedTabIndex];
    }
    
    // 获取当前 tab 下标
    NSInteger currentTabIndex = [self.tabButtons indexOfObject:button];
    
    // 回调
    if (_dataSourceFlags.didTapMenuAtTabIndex) {
        [self.cz_delegate menuView:self didTapMenuAtTabIndex:currentTabIndex];
    }
    
    // 判断显示与隐藏 下拉菜单
    if (currentTabIndex == self.selectedTabIndex) {
        // 隐藏
        [self hideDropMenuView];
    } else {
        // 显示
        // 记录选择的 tab 下标
        self.selectedTabIndex = currentTabIndex;
        NSTimeInterval time = self.showInWindow ? self.showDelay : 0.f;
        
        // 修改按钮文字颜色
        [button setImage:self.appearance.selectedImage forState:UIControlStateNormal];
        [button setTitleColor:self.appearance.tintColor forState:UIControlStateNormal];
        
        if (time > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showDropMenuView];
            });
        } else {
            [self showDropMenuView];
        }
    }
}

#pragma mark - 下拉菜单显示与隐藏相关方法
- (void)hideDropMenuView {
    [self animateMenuViewWithShow:NO];
    BOOL isScrollView = [self.superview isKindOfClass:[UIScrollView class]];
    if (isScrollView) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = YES;
    }
}

- (void)showDropMenuView {
    BOOL isScrollView = [self.superview isKindOfClass:[UIScrollView class]];
    if (isScrollView) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        CGFloat contentOffsetYBefore = scrollView.contentOffset.y;
        scrollView.scrollEnabled = NO;
        CGFloat contentOffsetYAfter = scrollView.contentOffset.y;
        self.adjustOffsetY = contentOffsetYBefore - contentOffsetYAfter;
    }
    
    [self animateMenuViewWithShow:YES];
}

/** 点击背景恢复默认, 收起下拉菜单 */
- (void)maskViewTappedClick:(UITapGestureRecognizer *)tap {
    // 修改上一个选中的按钮状态
    if (self.selectedTabIndex >= 0) {
        [self updateMenuTitleAtTabIndex:self.selectedTabIndex];
    }
    [self hideDropMenuView];
}

#pragma mark - ✨✨✨ 下拉菜单显示与隐藏 核心方法 ✨✨✨
- (void)animateMenuViewWithShow:(BOOL)show {
    
    self.selectedIndexPaths = [self.resultSelectedIndexPaths mutableCopy];
    self.inputTexts = [self.resultInputTexts mutableCopy];
    
    // 显示
    if (show) {
        [self.superview bringSubviewToFront:self];
        
        // 1. 添加灰色蒙版视图
        CGRect menuViewFrom = self.frame;
        UIView *superView = self.superview;
        
        CGFloat maskViewY = CGRectGetMaxY(menuViewFrom) - self.adjustOffsetY;
        CGFloat maskViewHeight = CGRectGetMaxY([UIScreen mainScreen].bounds); //  - maskViewY
        self.maskView.frame = CGRectMake(0, maskViewY, menuViewFrom.size.width, maskViewHeight);
        [superView addSubview:self.maskView];
        
        // 2. 添加筛选列表的容器视图, 高度设置为0, 动画做准备
        self.filerContainerView.frame = CGRectMake(0, maskViewY, menuViewFrom.size.width, 0);
        [superView addSubview:self.filerContainerView];
        
        // 3. 布局筛选列表
        // 3.1 获取需要用什么类型来展示:tableView\collectionView,默认tableView
        CZFilterMenuDownType downtype = CZFilterMenuDownTypeList;
        if (_dataSourceFlags.typeAtTabIndex) {
            downtype = [self.cz_dataSource menuView:self typeAtTabIndex:self.selectedTabIndex];
        }
        
        CGFloat filerContainerViewHeight = 0;
        if (downtype == CZFilterMenuDownTypeList) { // 使用tableView样式
            [self layoutTableViews];
            filerContainerViewHeight = [self heightForListTypeAtTabIndex:self.selectedTabIndex];
        } else {
            [self layoutCollectionViews];
            filerContainerViewHeight = [self heightForItemTypeAtTabIndex:self.selectedTabIndex];
        }
        
        CGFloat bottomConfirmViewHeight = 64.0;
        // 判断是否需要添加底部视图, 默认不需要
        CZFilterMenuConfirmType confirmType =  CZFilterMenuConfirmTypeSpeedConfirm;
        if (_dataSourceFlags.confirmTypeAtTabIndex) {
            confirmType = [self.cz_dataSource menuView:self confirmTypeAtTabIndex:self.selectedTabIndex];
        }
        
        if (confirmType == CZFilterMenuConfirmTypeBottomConfirm) {
            CGRect frame = CGRectMake(0, filerContainerViewHeight, superView.frame.size.width, bottomConfirmViewHeight);
            self.confirmView.frame = frame;
            [self.filerContainerView addSubview:self.confirmView];
            filerContainerViewHeight += bottomConfirmViewHeight;
        } else {
            [self.confirmView removeFromSuperview];
        }
        
        if (self.showInWindow) {
            CGRect frame = self.filerContainerView.frame;
            frame.size.height = filerContainerViewHeight;
            self.self.filerContainerView.frame = frame;
        } else {
            // 执行动画
            [UIView animateWithDuration:0.25 animations:^{
                self.maskView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
                CGRect frame = self.filerContainerView.frame;
                frame.size.height = filerContainerViewHeight;
                self.self.filerContainerView.frame = frame;
            }];
        }
    }
    
    // 隐藏
    else {
        self.selectedTabIndex = -1;
        [UIView animateWithDuration:0.25 animations:^{
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
            CGRect frame = self.filerContainerView.frame;
            frame.size.height = 0;
            self.filerContainerView.frame = frame;
        } completion:^(BOOL finished) {
            [self.filerContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.maskView removeFromSuperview];
        }];
    }
    
    self.showInWindow = show;
}

#pragma mark - tab 按钮文字及颜色处理
- (void)updateMenuTitleAtTabIndex:(NSUInteger)tabIndex {
    UIButton *button = self.tabButtons[tabIndex];
    UIImage *image = nil;
    UIColor *textColor = nil;
    NSString *defaultTitle = @"";
    
    if (_dataSourceFlags.titleAtTabIndex) {
        defaultTitle = [self.cz_dataSource menuView:self titleAtTabIndex:tabIndex];
    }
    
    CZFilterMenuDownType downtype = CZFilterMenuDownTypeList;
    if (_dataSourceFlags.typeAtTabIndex) {
        downtype = [self.cz_dataSource menuView:self typeAtTabIndex:tabIndex];
    }
    
    if (downtype == CZFilterMenuDownTypeList) {
        
        CZFilterIndexPath *indexPath = [self indexPathWithListTypeAtTabIndex:tabIndex inIndexPaths:self.resultSelectedIndexPaths];
        CZFilterMenuListType type = [self tableViewTypeAtIndexPath:indexPath];
        if (type == CZFilterMenuListTypeSingle) {
            textColor = indexPath.fRow > 0 ? self.appearance.tintColor : self.appearance.textColor;
            image = indexPath.fRow > 0 ? self.appearance.tintNormalImage : self.appearance.normalImage;
            
            if (_dataSourceFlags.titleForFRowsAtIndexPath) {
                defaultTitle = [self.cz_dataSource menuView:self titleForFRowsAtIndexPath:indexPath];
            }
            
        } else if (type == CZFilterMenuListTypeDouble) {
            textColor = indexPath.sRow > 0 ? self.appearance.tintColor : self.appearance.textColor;
            image = indexPath.sRow > 0 ? self.appearance.tintNormalImage : self.appearance.normalImage;
            
            if (indexPath.sRow > 0) {
                if (_dataSourceFlags.titleForSRowsAtIndexPath) {
                    defaultTitle = [self.cz_dataSource menuView:self titleForSRowsAtIndexPath:indexPath];
                }
            }
        } else if (type == CZFilterMenuListTypeTriple) {
            textColor = (indexPath.sRow > 0 || indexPath.tRow > 0) ? self.appearance.tintColor : self.appearance.textColor;
            image = (indexPath.sRow > 0 || indexPath.tRow > 0) ? self.appearance.tintNormalImage : self.appearance.normalImage;
            if (_dataSourceFlags.titleForTRowsAtIndexPath) {
                defaultTitle = [self.cz_dataSource menuView:self titleForTRowsAtIndexPath:indexPath];
            }
            
            if (indexPath.tRow > 0) {
                if (_dataSourceFlags.titleForTRowsAtIndexPath) {
                    defaultTitle = [self.cz_dataSource menuView:self titleForTRowsAtIndexPath:indexPath];
                }
            } else {
                if (indexPath.sRow > 0) {
                    if (_dataSourceFlags.titleForSRowsAtIndexPath) {
                        defaultTitle = [self.cz_dataSource menuView:self titleForSRowsAtIndexPath:indexPath];
                    }
                }
            }
        }
    }
    // collection类型
    else {
        NSInteger count = 0;
        if (_dataSourceFlags.numberOfFRowsInTab) {
            count = [self.cz_dataSource menuView:self numberOfFRowsInTab:tabIndex];
        }
        
        if (count == 0) return;
        
        NSSet *set = self.selectedIndexPaths[tabIndex];
        NSMutableArray *keys = [NSMutableArray array];
        for (CZFilterIndexPath *key in self.inputTexts.allKeys) {
            if (key.tab == tabIndex) {
                [keys addObject:key];
            }
        }
        
        NSUInteger resultCount = set.count + keys.count;
        
        // 更新tab文字及颜色
        textColor = resultCount > 0 ? self.appearance.tintColor : self.appearance.textColor;
        image = resultCount > 0 ? self.appearance.tintNormalImage : self.appearance.normalImage;
        
        if (count > 1) {
            defaultTitle = [NSString stringWithFormat:@"筛选(%@)", @(resultCount)];
        } else {
            if (resultCount > 1) {
                 defaultTitle = [NSString stringWithFormat:@"筛选(%@)", @(resultCount)];
            } else {
                if (set.count > 0) {
                    if (_dataSourceFlags.titleForSRowsAtIndexPath) {
                        defaultTitle = [self.cz_dataSource menuView:self titleForSRowsAtIndexPath:set.anyObject];
                    }
                } else {
                    for (CZFilterIndexPath *indexPath in keys) {
                        if (indexPath.tab == tabIndex) {
                            NSString *unit = @"";
                            if (_dataSourceFlags.placeholdersAtIndexPath) {
                                NSArray *placeholders = [self.cz_dataSource menuView:self placeholdersAtIndexPath:indexPath];
                                NSAssert(placeholders.count == 3, @"数组长度必须为3,且前2位是占位文字,第3位是单位");
                                if (placeholders.count == 3) {
                                    unit = placeholders[2];
                                }
                            }
                            NSArray *inputTexts = self.inputTexts[indexPath];
                            defaultTitle = [NSString stringWithFormat:@"%@-%@%@", inputTexts[0], inputTexts[1], unit];
                        }
                    }
                }
            }
        }
    }
  
    button.titleLabel.text = defaultTitle;
    [button setTitle:defaultTitle forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    [CZFilterMenuHelper layoutButtonWithButton:button imageTitleSpace:4.0];
}

#pragma mark - 点击事件处理
- (void)confirmClick {
    
    self.resultSelectedIndexPaths = [self.selectedIndexPaths mutableCopy];
    self.resultInputTexts = [self.inputTexts mutableCopy];
    
    // 存储到局部变量中,避免隐藏下拉菜单将selectedTabIndex置为-1时可能引起的bug
    NSUInteger tabIndex = self.selectedTabIndex;
    
    CZFilterMenuDownType downtype = CZFilterMenuDownTypeList;
    if (_dataSourceFlags.typeAtTabIndex) {
        downtype = [self.cz_dataSource menuView:self typeAtTabIndex:tabIndex];
    }
    
    // 使用tableView样式
    if (downtype == CZFilterMenuDownTypeList) {
            [self hideDropMenuView];
        // 代理回调
        NSSet *set = self.resultSelectedIndexPaths[tabIndex];
        if (set.count > 0) {
            if (_dataSourceFlags.didSelectedMenuAtIndexPath) {
                for (CZFilterIndexPath *indexPath in set) {
                    [self.cz_delegate menuView:self didSelectedMenuAtIndexPath:indexPath];
                }
            }
        } else {
            if (_dataSourceFlags.clearFilterConditionAtTabIndex) {
                [self.cz_delegate menuView:self clearFilterConditionAtTabIndex:tabIndex];
            }
        }
       
    }
    // collectionView 样式
    else {
        NSSet *set = self.selectedIndexPaths[tabIndex];
        NSArray *keys = [self.resultInputTexts allKeys];
        NSUInteger resultCount = set.count + keys.count;
        
        if (resultCount == 0) {
            if (_dataSourceFlags.clearFilterConditionAtTabIndex) {
                [self.cz_delegate menuView:self clearFilterConditionAtTabIndex:tabIndex];
            }
        } else {
            if (_dataSourceFlags.didSelectedMenuAtIndexPath) {
                for (CZFilterIndexPath *indexPath in set) {
                    [self.cz_delegate menuView:self didSelectedMenuAtIndexPath:indexPath];
                }
            }
            
            if (_dataSourceFlags.inputTexts) {
                for (CZFilterIndexPath *indexPath in keys) {
                    if (indexPath.tab == tabIndex) {
                        NSArray *inputTexts = [self.resultInputTexts objectForKey:indexPath];
                        if (inputTexts != nil) {
                            double leftInput = [inputTexts[0] doubleValue];
                            double rightInput = [inputTexts[1] doubleValue];
                            if (leftInput > rightInput) {
                                if (_dataSourceFlags.inputTextsFailureAtIndexPath) {
                                    [self.cz_delegate menuView:self inputTextsFailureAtIndexPath:indexPath];
                                }
                                return;
                            }
                            [self.cz_delegate menuView:self inputTexts:inputTexts indexPath:indexPath];
                        }
                    }
                }
            }
        }
        [self hideDropMenuView];
    }
    
    [self updateMenuTitleAtTabIndex:tabIndex];
}

#pragma mark - 重置
- (void)resetClick {
    
    // 存储到局部变量中,避免隐藏下拉菜单将selectedTabIndex置为-1时可能引起的bug
    NSUInteger tabIndex = self.selectedTabIndex;
    
    CZFilterMenuDownType downtype = CZFilterMenuDownTypeList;
    if (_dataSourceFlags.typeAtTabIndex) {
        downtype = [self.cz_dataSource menuView:self typeAtTabIndex:tabIndex];
    }
    
    if (downtype == CZFilterMenuDownTypeList) {
        self.selectedIndexPaths[tabIndex] = [NSSet set];
        [self managerListViewsHierachy];
    } else {
        if (_dataSourceFlags.numberOfFRowsInTab) {
            // 判断是否有输入数据,如果有则需要将其置空
            NSArray *keys = [self.inputTexts allKeys];
            for (CZFilterIndexPath *indexPath in keys) {
                if (indexPath.tab == tabIndex) {
                    NSArray *inputTexts = self.inputTexts[indexPath];
                    if (inputTexts != nil) {
                        [self.inputTexts removeObjectForKey:indexPath];
                    }
                }
            }
            
            self.selectedIndexPaths[tabIndex] = [NSSet set];
            NSInteger count = [self.cz_dataSource menuView:self numberOfFRowsInTab:tabIndex];
            if (count < 2) {
                
                [self confirmClick];
                
                if (_dataSourceFlags.clearFilterConditionAtTabIndex) {
                    [self.cz_delegate menuView:self clearFilterConditionAtTabIndex:tabIndex];
                }
                return;
            }
            
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - <---------------------  List 样式布局相关 开始  --------------------->
- (void)layoutTableViews {
    // 1.删除之前布局的collectionView
    for (UIView *view in self.filerContainerView.subviews) {
        if ([view isKindOfClass:[UICollectionView class]]) {
            [view removeFromSuperview];
        }
    }
    
    // 2.将最左侧的tableView offset置为 {0.0, 0.0}
    [self.leftTableView setContentOffset:CGPointZero animated:NO];
    
    // 3.管理三个tableView的显示与否,及frame的设置
    [self managerListViewsHierachy];
    
    // 4. 滚动到选中的row
    [self listViewScrollToSelectedIndexPath];
}

// 管理三个tableView的显示与否,及frame的设置
- (void)managerListViewsHierachy {
    
    CGRect menuViewFrom = self.frame;
    CGFloat tableViewHeight = [self heightForListTypeAtTabIndex:self.selectedTabIndex];
    
    CZFilterIndexPath *indexPath = [self indexPathWithListTypeAtTabIndex:self.selectedTabIndex];
    CZFilterMenuListType type = [self tableViewTypeAtIndexPath:indexPath];
    
    CGFloat leftTableViewWidth = self.appearance.cutomFirstTableViewWidthWhenMuti;
    CGFloat centerTableViewWidth = self.appearance.cutomSecondTableViewWidthWhenMuti;
    
    // 创建各种情况下的tableView
    if (type == CZFilterMenuListTypeSingle) {
        self.leftTableView.frame = CGRectMake(menuViewFrom.origin.x, 0, menuViewFrom.size.width, tableViewHeight);
        [self.filerContainerView addSubview:self.leftTableView];
        [self.centerTableView removeFromSuperview];
        [self.rightTableView removeFromSuperview];
    } else if (type == CZFilterMenuListTypeDouble) {
        self.leftTableView.frame = CGRectMake(menuViewFrom.origin.x, 0, leftTableViewWidth, tableViewHeight);
        self.centerTableView.frame = CGRectMake(leftTableViewWidth, 0, menuViewFrom.size.width - leftTableViewWidth, tableViewHeight);
        [self.filerContainerView addSubview:self.leftTableView];
        [self.filerContainerView addSubview:self.centerTableView];
        [self.rightTableView removeFromSuperview];
    } else if (type == CZFilterMenuListTypeTriple) {
        self.leftTableView.frame = CGRectMake(menuViewFrom.origin.x, 0, leftTableViewWidth, tableViewHeight);
        self.centerTableView.frame = CGRectMake(leftTableViewWidth, 0, centerTableViewWidth, tableViewHeight);
        self.rightTableView.frame = CGRectMake(leftTableViewWidth + centerTableViewWidth, 0, menuViewFrom.size.width - leftTableViewWidth - centerTableViewWidth, tableViewHeight);
        [self.filerContainerView addSubview:self.leftTableView];
        [self.filerContainerView addSubview:self.centerTableView];
        [self.filerContainerView addSubview:self.rightTableView];
    }
    
    [self.leftTableView reloadData];
    [self.centerTableView reloadData];
    [self.rightTableView reloadData];
}

- (void)listViewScrollToSelectedIndexPath {
    CZFilterIndexPath *indexPath = [self indexPathWithListTypeAtTabIndex:self.selectedTabIndex];
    CZFilterMenuListType type = [self tableViewTypeAtIndexPath:indexPath];
    
    // 创建各种情况下的tableView
    if (type == CZFilterMenuListTypeSingle) {
        NSIndexPath *leftIndexPath = [NSIndexPath indexPathForRow:indexPath.fRow inSection:0];
        [self.leftTableView scrollToRowAtIndexPath:leftIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    } else if (type == CZFilterMenuListTypeDouble) {
        NSIndexPath *leftIndexPath = [NSIndexPath indexPathForRow:indexPath.fRow inSection:0];
        [self.leftTableView scrollToRowAtIndexPath:leftIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        NSIndexPath *centerIndexPath = [NSIndexPath indexPathForRow:indexPath.sRow inSection:0];
        [self.centerTableView scrollToRowAtIndexPath:centerIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    } else if (type == CZFilterMenuListTypeTriple) {
        NSIndexPath *leftIndexPath = [NSIndexPath indexPathForRow:indexPath.fRow inSection:0];
        [self.leftTableView scrollToRowAtIndexPath:leftIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        NSIndexPath *centerIndexPath = [NSIndexPath indexPathForRow:indexPath.sRow inSection:0];
        [self.centerTableView scrollToRowAtIndexPath:centerIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        NSIndexPath *rightIndexPath = [NSIndexPath indexPathForRow:indexPath.tRow inSection:0];
        [self.rightTableView scrollToRowAtIndexPath:rightIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)listTypeDidSeletedIndexPath {
    [self confirmClick];
}

#pragma mark - 返回list类型下,合适的高度
- (CGFloat)heightForListTypeAtTabIndex:(NSUInteger)tabIndex {
    CZFilterIndexPath *indexPath = [self indexPathWithListTypeAtTabIndex:tabIndex];
    NSInteger maxCount = 0;
    NSInteger numberOfFRows = 0;
    
    if (_dataSourceFlags.numberOfFRowsInTab) {
        numberOfFRows = [self.cz_dataSource menuView:self numberOfFRowsInTab:indexPath.tab];
    }
    
    maxCount = numberOfFRows;
    
    for (int fRow = 0; fRow < numberOfFRows; fRow++) {
        NSInteger numberOfSRows = 0;
        if (_dataSourceFlags.numberOfSRowsInFRow) {
            numberOfSRows = [self.cz_dataSource menuView:self numberOfSRowsInFRow:fRow tab:indexPath.tab];
        }
        maxCount = MAX(maxCount, numberOfSRows);
        
        for (int sRow = 0; sRow < numberOfSRows; sRow++) {
            NSInteger numberOftRows = 0;
            if (_dataSourceFlags.numberOfTRowsInSRow) {
                numberOftRows = [self.cz_dataSource menuView:self numberOfTRowsInSRow:sRow fRow:fRow tab:indexPath.tab];
            }
            maxCount = MAX(maxCount, numberOftRows);
        }
    }
    
    CGFloat viewHeight = maxCount * kTableViewRowHeight;
    return MIN(252.0, viewHeight);
}

#pragma mark - list类型下 返回 一个CZFilterIndexPath对象
- (CZFilterIndexPath *)indexPathWithListTypeAtTabIndex:(NSUInteger)tabIndex {
    return [self indexPathWithListTypeAtTabIndex:tabIndex inIndexPaths:self.selectedIndexPaths];
}

- (CZFilterIndexPath *)indexPathWithListTypeAtTabIndex:(NSUInteger)tabIndex inIndexPaths:(NSArray *)indexPaths {
    NSSet *set = indexPaths[tabIndex];
    if (set.count > 0) {
        return set.anyObject;
    }
    return [CZFilterIndexPath indexPathWithTab:tabIndex];
}

#pragma mark - 查询当前需要展示几级列表
- (CZFilterMenuListType)tableViewTypeAtIndexPath:(CZFilterIndexPath *)indexPath {
    
    // 查看是不是一级列表
    NSInteger fCount = 0;
    if (_dataSourceFlags.numberOfFRowsInTab) {
        fCount = [self.cz_dataSource menuView:self numberOfFRowsInTab:indexPath.tab];
    }
    
    // 查看是不是二级列表
    NSInteger sCount = 0;
    if (_dataSourceFlags.numberOfSRowsInFRow) {
        sCount = [self.cz_dataSource menuView:self numberOfSRowsInFRow:indexPath.fRow tab:indexPath.tab];
    }
    
    // 查看是不是三级列表
    NSInteger tCount = 0;
    if (_dataSourceFlags.numberOfTRowsInSRow) {
        tCount = [self.cz_dataSource menuView:self numberOfTRowsInSRow:indexPath.sRow fRow:indexPath.fRow tab:indexPath.tab];
    }
    
    if (tCount > 0 && sCount > 0 && fCount > 0) {
        return CZFilterMenuListTypeTriple;
    }
    
    if (tCount <= 0 && sCount > 0 && fCount > 0) {
        return CZFilterMenuListTypeDouble;
    }
    
    if (fCount > 0) {
        return CZFilterMenuListTypeSingle;
    }
    
    return CZFilterMenuListTypeUnKnow;
}

#pragma mark - UITableViewDadaSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CZFilterIndexPath *indexPath = [self indexPathWithListTypeAtTabIndex:self.selectedTabIndex];
    if (tableView == self.leftTableView) {
        if (_dataSourceFlags.numberOfFRowsInTab) {
            return [self.cz_dataSource menuView:self numberOfFRowsInTab:indexPath.tab];
        }
    } else if (tableView == self.centerTableView) {
        if (_dataSourceFlags.numberOfSRowsInFRow) {
            return [self.cz_dataSource menuView:self numberOfSRowsInFRow:indexPath.fRow tab:indexPath.tab];
        }
    } else {
        if (_dataSourceFlags.numberOfTRowsInSRow) {
            return [self.cz_dataSource menuView:self numberOfTRowsInSRow:indexPath.sRow fRow:indexPath.fRow tab:indexPath.tab];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CZFilterMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellId
                                                                      forIndexPath:indexPath];
    CZFilterIndexPath *sourceIndexPath = [self indexPathWithListTypeAtTabIndex:self.selectedTabIndex];
    CZFilterIndexPath *targetIndexPath = [sourceIndexPath copy];
    
    NSString *title = @"";
    if (tableView == self.leftTableView) {
        targetIndexPath.fRow = indexPath.row;
        if (_dataSourceFlags.titleForFRowsAtIndexPath) {
            title = [self.cz_dataSource menuView:self titleForFRowsAtIndexPath:targetIndexPath];
        }
    } else if (tableView == self.centerTableView) {
        targetIndexPath.sRow = indexPath.row;
        if (_dataSourceFlags.titleForSRowsAtIndexPath) {
            title = [self.cz_dataSource menuView:self titleForSRowsAtIndexPath:targetIndexPath];
        }
    } else {
        targetIndexPath.tRow = indexPath.row;
        if (_dataSourceFlags.titleForTRowsAtIndexPath) {
            title = [self.cz_dataSource menuView:self titleForTRowsAtIndexPath:targetIndexPath];
        }
    }
    cell.titleLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!cell.backgroundView) {
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    }
    
    CZFilterIndexPath *selectedIndexPath = [self indexPathWithListTypeAtTabIndex:self.selectedTabIndex];
    CZFilterMenuTableViewCell *displayCell = (CZFilterMenuTableViewCell *)cell;
    displayCell.titleLabel.font = [UIFont systemFontOfSize:self.appearance.cellFontSize];
    
    if (tableView == self.leftTableView) {
        UIColor *color = selectedIndexPath.fRow == indexPath.row ? [[UIColor alloc] initWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1] : [[UIColor alloc] initWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1];
        cell.backgroundView.backgroundColor = color;
        displayCell.titleLabel.textColor = indexPath.row == selectedIndexPath.fRow ? self.appearance.tintColor : self.appearance.textColor;
    } else if (tableView == self.centerTableView) {
        UIColor *color = selectedIndexPath.sRow == indexPath.row ? [[UIColor alloc] initWithRed:254.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1] : [[UIColor alloc] initWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
        cell.backgroundView.backgroundColor = color;
        displayCell.titleLabel.textColor = indexPath.row == selectedIndexPath.sRow ? self.appearance.tintColor : self.appearance.textColor;
    } else {
        cell.backgroundView.backgroundColor = [[UIColor alloc] initWithRed:254.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1];
        displayCell.titleLabel.textColor = indexPath.row == selectedIndexPath.tRow ? self.appearance.tintColor : self.appearance.textColor;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CZFilterIndexPath *sourceIndexPath = [self indexPathWithListTypeAtTabIndex:self.selectedTabIndex];
    CZFilterIndexPath *targetIndexPath = [sourceIndexPath copy];
    
    BOOL centerTableViewScrollToTop = NO;
    BOOL rightTableViewScrollToTop = NO;
    
    if (tableView == self.leftTableView) {
        targetIndexPath.fRow = indexPath.row;
        targetIndexPath.sRow = 0;
        targetIndexPath.tRow = 0;
        centerTableViewScrollToTop = YES;
        rightTableViewScrollToTop = YES;
    } else if (tableView == self.centerTableView){
        targetIndexPath.sRow = indexPath.row;
        targetIndexPath.tRow = 0;
        rightTableViewScrollToTop = YES;
    } else {
        targetIndexPath.tRow = indexPath.row;
    }
    
    // 将选中结果存储到数组中
    NSSet *set = [NSSet setWithObject:targetIndexPath];
    self.selectedIndexPaths[self.selectedTabIndex] = set;
    
    // 如果是speedConfirm 直接返回,不会对列表进行刷新操作
    CZFilterMenuConfirmType confirmType = CZFilterMenuConfirmTypeSpeedConfirm;
    if (_dataSourceFlags.confirmTypeAtTabIndex) {
        confirmType = [self.cz_dataSource menuView:self confirmTypeAtTabIndex:targetIndexPath.tab];
    }
    
    if (confirmType == CZFilterMenuConfirmTypeSpeedConfirm) {
        
        CZFilterIndexPath *indexPath = [self indexPathWithListTypeAtTabIndex:self.selectedTabIndex];
        CZFilterMenuListType type = [self tableViewTypeAtIndexPath:indexPath];
        if (type == CZFilterMenuListTypeSingle) {
            [self listTypeDidSeletedIndexPath];
            return;
        }
        
        if (type == CZFilterMenuListTypeDouble && tableView == self.centerTableView) {
            [self listTypeDidSeletedIndexPath];
            return;
        }
        
        if (type == CZFilterMenuListTypeTriple && tableView == self.rightTableView) {
            [self listTypeDidSeletedIndexPath];
            return;
        }
    }
    
    if (centerTableViewScrollToTop) {
        [self.centerTableView setContentOffset:CGPointZero animated:NO];
    }
    
    if (rightTableViewScrollToTop) {
        [self.rightTableView setContentOffset:CGPointZero animated:NO];
    }
    
    if (![targetIndexPath isEqual:sourceIndexPath]) {
        if (centerTableViewScrollToTop || rightTableViewScrollToTop) {
            [self managerListViewsHierachy];
        } else {
            [tableView reloadData];
        }
    }
}

#pragma mark - <---------------------  List 样式布局相关 结束  --------------------->
#pragma mark - <---------------------  Item 样式布局相关 开始  --------------------->
- (void)layoutCollectionViews {
    // 1.删除之前布局的tableView
    for (UIView *view in self.filerContainerView.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            [view removeFromSuperview];
        }
    }
    
    CGRect menuViewFrom = self.frame;
    CGFloat viewHeight = [self heightForItemTypeAtTabIndex:self.selectedTabIndex];
    self.collectionView.frame = CGRectMake(menuViewFrom.origin.x, 0, menuViewFrom.size.width, viewHeight);
    [self.filerContainerView addSubview:self.collectionView];
    [self.collectionView reloadData];
}

#pragma mark - 返回item类型下,合适的高度
- (CGFloat)heightForItemTypeAtTabIndex:(NSUInteger)tabIndex {
    // item模式下, 只支持2级列表
    
    NSInteger sectionCount = 0;
    if (_dataSourceFlags.numberOfFRowsInTab) {
        sectionCount = [self.cz_dataSource menuView:self numberOfFRowsInTab:tabIndex];
    }
    
    CGFloat headerViewTotalHeight = kCollectionSectioinHeaderHeight * sectionCount;
    NSInteger total = headerViewTotalHeight + kCollectionContentInsets.top + kCollectionContentInsets.bottom;
    for (int i = 0; i < sectionCount; i++) {
        NSInteger itemCount = 0;
        if (_dataSourceFlags.numberOfSRowsInFRow) {
            itemCount = [self.cz_dataSource menuView:self numberOfSRowsInFRow:i tab:tabIndex];
        }
        
        // 得到布局行数
        NSInteger row = itemCount / kCollectionNumberOfColumn;
        NSInteger extra = itemCount % kCollectionNumberOfColumn;
        if (extra > 0) {
            row += 1;
        }
        // 计算总高度
        total += (kCollectionItemHeight * row + kCollectionLineSpacing * (row - 1));
        
        // 询问是否需要包含footer
        if (_dataSourceFlags.heightForFooterAtIndexPath) {
            CGFloat height = [self.cz_dataSource menuView:self heightForFooterAtIndexPath:[CZFilterIndexPath indexPathWithTab:tabIndex fRow:i]];
            if (height > 0) {
                total += height;
            }
        }
    }
    
    return MIN(400, total);
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_dataSourceFlags.numberOfFRowsInTab) {
        return [self.cz_dataSource menuView:self numberOfFRowsInTab:self.selectedTabIndex];
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_dataSourceFlags.numberOfSRowsInFRow) {
        return [self.cz_dataSource menuView:self numberOfSRowsInFRow:section tab:self.selectedTabIndex];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CZFilterMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CZFilterMenuCollectionViewCell class])
                                                                                     forIndexPath:indexPath];
    
    CZFilterIndexPath *targetIndexPath = [CZFilterIndexPath indexPathWithTab:self.selectedTabIndex
                                                                        fRow:indexPath.section
                                                                        sRow:indexPath.row];
    
    cell.titleLabel.font = [UIFont systemFontOfSize:self.appearance.itemCellFontSize];
    if (_dataSourceFlags.titleForSRowsAtIndexPath) {
        cell.titleLabel.text = [self.cz_dataSource menuView:self titleForSRowsAtIndexPath:targetIndexPath];
    }
    
    // 如果有输入值,则列表为不选中状态
    NSArray *inputTexts = self.inputTexts[targetIndexPath];
    if (inputTexts != nil) {
        cell.titleLabel.textColor = self.appearance.textColor;
        cell.contentView.backgroundColor = self.appearance.backgroundColor;
    } else {
        NSSet *set = self.selectedIndexPaths[self.selectedTabIndex];
        if ([set containsObject:targetIndexPath]) {
            cell.titleLabel.textColor = self.appearance.tintColor;
            cell.contentView.backgroundColor = self.appearance.backgroundTintColor;
        } else {
            cell.titleLabel.textColor = self.appearance.textColor;
            cell.contentView.backgroundColor = self.appearance.backgroundColor;
        }
    }
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader){
        CZFilterMenuCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                          withReuseIdentifier:kCollectionViewHeaderId
                                                                                                 forIndexPath:indexPath];
        headerView.titleLabel.font = [UIFont systemFontOfSize:self.appearance.itemHeaderFontSize];
        headerView.titleLabel.textColor = self.appearance.textColor;
        if (_dataSourceFlags.titleForFRowsAtIndexPath) {
            CZFilterIndexPath *filterIndexPath = [CZFilterIndexPath indexPathWithTab:self.selectedTabIndex
                                                                                fRow:indexPath.section
                                                                                sRow:indexPath.row];
            headerView.titleLabel.text = [self.cz_dataSource menuView:self titleForFRowsAtIndexPath:filterIndexPath];
        }
        return headerView;
    } else {
        CZFilterMenuCollectionFooterInputView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                               withReuseIdentifier:kCollectionViewFooterId
                                                                                                      forIndexPath:indexPath];
        footerView.leftTextfield.placeholder = nil;
        footerView.rightTextfield.placeholder = nil;
        footerView.leftTextfield.text = nil;
        footerView.rightTextfield.text = nil;
        
        footerView.label.textColor = self.appearance.textColor;
        footerView.label.font = [UIFont systemFontOfSize:self.appearance.itemCellFontSize];
        footerView.leftTextfield.textColor = self.appearance.textColor;
        footerView.rightTextfield.textColor = self.appearance.textColor;
        
        CZFilterIndexPath *filterIndexPath = [CZFilterIndexPath indexPathWithTab:self.selectedTabIndex
                                                                            fRow:indexPath.section
                                                                            sRow:0];
        
        if (_dataSourceFlags.placeholdersAtIndexPath) {
            NSArray *placeholders = [self.cz_dataSource menuView:self placeholdersAtIndexPath:filterIndexPath];
            NSAssert(placeholders.count == 3, @"数组长度必须为3,且前2位是占位文字,第3位是单位");
            if (placeholders.count == 3) {
                footerView.leftTextfield.placeholder = placeholders[0];
                footerView.rightTextfield.placeholder = placeholders[1];
            }
        }
        
        NSArray *inputTexts = self.inputTexts[filterIndexPath];
        if (inputTexts != nil) {
            footerView.leftTextfield.text = inputTexts[0];
            footerView.rightTextfield.text = inputTexts[1];
        }
        
        footerView.textChangeHandler = ^(NSArray * _Nonnull inputTexts) {
            self.inputTexts[filterIndexPath] = inputTexts;
            NSMutableSet *set = [self.selectedIndexPaths[self.selectedTabIndex] mutableCopy];
            CZFilterIndexPath *removeIndexPath = nil;
            for (CZFilterIndexPath *selectedIndexPath in set) {
                if (selectedIndexPath.tab == filterIndexPath.tab && selectedIndexPath.fRow == filterIndexPath.fRow) {
                    removeIndexPath = selectedIndexPath;
                }
            }
            if (removeIndexPath != nil) {
                [set removeObject:removeIndexPath];
            }
            self.selectedIndexPaths[self.selectedTabIndex] = [set copy];
        };
        return footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (_dataSourceFlags.heightForFooterAtIndexPath) {
        CGFloat height = [self.cz_dataSource menuView:self heightForFooterAtIndexPath:[CZFilterIndexPath indexPathWithTab:self.selectedTabIndex fRow:section]];
        if (height > 0) {
            return CGSizeMake(collectionView.frame.size.width, height);
        }
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 判断是否有输入数据,如果有则需要将其置空
    CZFilterIndexPath *inputIndexPAth = [CZFilterIndexPath indexPathWithTab:self.selectedTabIndex
                                                                       fRow:indexPath.section
                                                                       sRow:0];
    NSArray *inputTexts = self.inputTexts[inputIndexPAth];
    if (inputTexts != nil) {
        [self.inputTexts removeObjectForKey:inputIndexPAth];
    }
    
    CZFilterIndexPath *targetIndexPath = [CZFilterIndexPath indexPathWithTab:self.selectedTabIndex
                                                                        fRow:indexPath.section
                                                                        sRow:indexPath.row];
    
    NSMutableSet *set = [self.selectedIndexPaths[self.selectedTabIndex] mutableCopy];
    
    // 如果已经存在则需要取消选中
    if ([set containsObject:targetIndexPath]) {
        [set removeObject:targetIndexPath];
    } else {
        // 询问是否需要多选
        BOOL mutiSelected = NO;
        if (_dataSourceFlags.mutiSelectedAtIndexPath) {
            mutiSelected = [self.cz_dataSource menuView:self mutiSelectedAtIndexPath:targetIndexPath];
        }
        
        // 如果不需要,则需要找到对应section的indexpath,将其取消选中
        if (!mutiSelected) {
            CZFilterIndexPath *existIndex = nil;
            for (CZFilterIndexPath *selectedIndex in set) {
                // 同一个section不允许存在多个
                if (selectedIndex.tab == targetIndexPath.tab && selectedIndex.fRow == targetIndexPath.fRow) {
                    existIndex = selectedIndex;
                }
            }
            
            if (existIndex != nil) {
                [set removeObject:existIndex];
            }
        }
        [set addObject:targetIndexPath];
    }
    
    self.selectedIndexPaths[self.selectedTabIndex] = [set copy];
    [collectionView reloadData];
}

#pragma mark - <---------------------  Item 样式布局相关 结束  --------------------->

#pragma mark - 懒加载
- (NSMutableArray<NSSet *> *)selectedIndexPaths {
    if (!_selectedIndexPaths) {
        NSMutableArray *array = [NSMutableArray array];
        NSInteger menuCount = 0;
        if (_dataSourceFlags.numberOfTabInMenuView) {
            menuCount = [self.cz_dataSource numberOfTabInMenuView:self];
        }
        for (int i = 0; i < menuCount; i++) {
            NSSet *set = [NSSet set];
            [array addObject:set];
        }
        _selectedIndexPaths = [array mutableCopy];
    }
    return _selectedIndexPaths;
}

- (NSMutableArray<NSSet *> *)resultSelectedIndexPaths {
    if (!_resultSelectedIndexPaths) {
        NSMutableArray *array = [NSMutableArray array];
        NSInteger menuCount = 0;
        if (_dataSourceFlags.numberOfTabInMenuView) {
            menuCount = [self.cz_dataSource numberOfTabInMenuView:self];
        }
        for (int i = 0; i < menuCount; i++) {
            NSSet *set = [NSSet set];
            [array addObject:set];
        }
        _resultSelectedIndexPaths = [array mutableCopy];
    }
    return _resultSelectedIndexPaths;
}

- (NSMutableDictionary *)inputTexts {
    if (!_inputTexts) {
        _inputTexts = [NSMutableDictionary dictionary];
    }
    return _inputTexts;
}

- (NSMutableDictionary *)resultInputTexts {
    if (!_resultInputTexts) {
        _resultInputTexts = [NSMutableDictionary dictionary];
    }
    return _resultInputTexts;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.opaque = NO;
        _maskView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTappedClick:)];
        [_maskView addGestureRecognizer:gesture];
    }
    return _maskView;
}

- (UIView *)filerContainerView {
    if (!_filerContainerView) {
        _filerContainerView = [[UIView alloc] init];
        _filerContainerView.clipsToBounds = YES;
    }
    return _filerContainerView;
}

- (CZBottomConfirmView *)confirmView {
    if (!_confirmView) {
        NSBundle *bundle = [CZFilterMenuHelper libBundle];
        _confirmView = [[bundle loadNibNamed:NSStringFromClass([CZBottomConfirmView class]) owner:nil options:nil] firstObject];
        _confirmView.resetImageView.image = [UIImage imageNamed:@"filter_clear" inBundle:bundle compatibleWithTraitCollection:nil];
        _confirmView.confirmButton.backgroundColor = self.appearance.tintColor;
        _confirmView.resetLabel.textColor = self.appearance.textColor;
        [_confirmView.confirmButton addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetClick)];
        [_confirmView.resetView addGestureRecognizer:tap];
    }
    return _confirmView;
}

- (UITableView *)leftTableView {
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.rowHeight = kTableViewRowHeight;
        _leftTableView.showsVerticalScrollIndicator = NO;
        _leftTableView.tableFooterView = [[UIView alloc] init];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1.0];
        [_leftTableView registerNib:[UINib nibWithNibName:NSStringFromClass([CZFilterMenuTableViewCell class]) bundle:[CZFilterMenuHelper libBundle]]
             forCellReuseIdentifier:kTableViewCellId];
    }
    return _leftTableView;
}

- (UITableView *)centerTableView {
    if (!_centerTableView) {
        _centerTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _centerTableView.delegate = self;
        _centerTableView.dataSource = self;
        _centerTableView.rowHeight = kTableViewRowHeight;
        _centerTableView.showsVerticalScrollIndicator = NO;
        _centerTableView.tableFooterView = [[UIView alloc] init];
        _centerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _centerTableView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1.0];
        [_centerTableView registerNib:[UINib nibWithNibName:NSStringFromClass([CZFilterMenuTableViewCell class]) bundle:[CZFilterMenuHelper libBundle]]
               forCellReuseIdentifier:kTableViewCellId];
    }
    return _centerTableView;
}

- (UITableView *)rightTableView {
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.rowHeight = kTableViewRowHeight;
        _rightTableView.showsVerticalScrollIndicator = NO;
        _rightTableView.tableFooterView = [[UIView alloc] init];
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _rightTableView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1.0];
        [_rightTableView registerNib:[UINib nibWithNibName:NSStringFromClass([CZFilterMenuTableViewCell class]) bundle:[CZFilterMenuHelper libBundle]]
              forCellReuseIdentifier:kTableViewCellId];
    }
    return _rightTableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kCollectionLineSpacing;
        layout.minimumInteritemSpacing = kCollectionLineSpacing;
        CGFloat itemWith = (self.frame.size.width - kCollectionLineSpacing * (kCollectionNumberOfColumn - 1) - kCollectionContentInsets.left - kCollectionContentInsets.right) / kCollectionNumberOfColumn;
        layout.itemSize = CGSizeMake(itemWith, kCollectionItemHeight);
        layout.headerReferenceSize = CGSizeMake(self.frame.size.width, kCollectionSectioinHeaderHeight);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.contentInset = kCollectionContentInsets;
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CZFilterMenuCollectionViewCell class]) bundle:[CZFilterMenuHelper libBundle]]
          forCellWithReuseIdentifier:kCollectionViewCellId];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CZFilterMenuCollectionHeaderView class]) bundle:[CZFilterMenuHelper libBundle]]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:kCollectionViewHeaderId];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CZFilterMenuCollectionFooterInputView class]) bundle:[CZFilterMenuHelper libBundle]]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:kCollectionViewFooterId];
        
    }
    return _collectionView;
}
@end
