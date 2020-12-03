//
//  ViewController.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "ViewController.h"
#import "CZFilterMenuView.h"
#import "MJExtension/MJExtension.h"
#import "CZAreaModel.h"
#import "CZSubwayModel.h"
#import "CZFilterMenuModel.h"

@interface ViewController () <CZFilterMenuViewDetaSource, CZFilterMenuViewDelegate>
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSArray *dictArr;
@property (nonatomic, copy) NSString *inputTexts;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UINavigationBar appearance];
    
    CGFloat width = CGRectGetMaxX([UIScreen mainScreen].bounds);
    CZFilterMenuAppearance *configure = [[CZFilterMenuAppearance alloc] init];
    configure.textColor = [UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1.0];
    configure.tintColor = [UIColor colorWithRed:47.0/255.0 green:115.0/255.0 blue:246.0/255.0 alpha:1.0];
    configure.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    configure.backgroundTintColor = [UIColor colorWithRed:0.96 green:0.98 blue:0.96 alpha:1.0];
    CZFilterMenuView *menuView = [[CZFilterMenuView alloc] initWithFrame:CGRectMake(0, 200, width, 44.0) appearance:configure];
    menuView.cz_dataSource = self;
    menuView.cz_delegate = self;
    menuView.backgroundColor = UIColor.redColor;
    [self.view addSubview:menuView];
    
    self.titles = @[@"区域", @"用途", @"价格", @"排序"];
    
    
    self.rows = @[@[@"0"], @[@"1"], @[@"2"], @[@"3"]];
    
    // 创建区域相关数据
    CZFilterMenuModel *areaModel = [[CZFilterMenuModel alloc] initWithName:@"区域"];
    
    // 区域
    NSString *areaPath = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"json"];
    NSString *areaJson = [[NSString alloc] initWithContentsOfFile:areaPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *areaArray = [CZAreaModel mj_objectArrayWithKeyValuesArray:areaJson];
    
    NSMutableArray *areas = [NSMutableArray array];
    CZFilterMenuModel *aaa = [[CZFilterMenuModel alloc] init];
    aaa.name = @"不限";
    aaa.code = @"0";
    [areas addObject:aaa];
    
    for (CZAreaModel *area in areaArray) {
        CZFilterMenuModel *model = [[CZFilterMenuModel alloc] init];
        model.name = area.area;
        model.code = area.areaId;
        [areas addObject:model];
    }
    
    // 地铁
    NSString *subwayPath = [[NSBundle mainBundle] pathForResource:@"subway" ofType:@"json"];
    NSString *subwayJson = [[NSString alloc] initWithContentsOfFile:subwayPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *subwayArray = [CZSubwayModel mj_objectArrayWithKeyValuesArray:subwayJson];
    
    NSMutableArray *subways = [NSMutableArray array];
    CZFilterMenuModel *bbb = [[CZFilterMenuModel alloc] init];
    bbb.name = @"不限";
    bbb.code = @"0";
    [subways addObject:bbb];
    for (CZSubwayModel *subway in subwayArray) {
        CZFilterMenuModel *model = [[CZFilterMenuModel alloc] init];
        model.name = subway.lineName;
        model.code = [NSString stringWithFormat:@"%@", @(subway.lineId)];
        NSMutableArray *stations = [NSMutableArray array];
        
        CZFilterMenuModel *ccc = [[CZFilterMenuModel alloc] init];
        ccc.name = @"不限";
        ccc.code = @"0";
        [stations addObject:ccc];
        
        for (CZStationModel *station in subway.stationList) {
            CZFilterMenuModel *model = [[CZFilterMenuModel alloc] init];
            model.name = station.stationName;
            model.code = [NSString stringWithFormat:@"%@", @(station.stationId)];
            [stations addObject:model];
        }
        model.filters = [stations copy];
        [subways addObject:model];
    }
    
    CZFilterMenuModel *areaModel1 = [[CZFilterMenuModel alloc] initWithName:@"区域" code:@"0" filters:areas];
    CZFilterMenuModel *subwayModel = [[CZFilterMenuModel alloc] initWithName:@"地铁" code:@"0" filters:subways];
    
    areaModel.filters = @[areaModel1, subwayModel];
    
    // 用途
    CZFilterMenuModel *useModel = [[CZFilterMenuModel alloc] initWithName:@"用途"];
    CZFilterMenuModel *useModel1 = [[CZFilterMenuModel alloc] initWithName:@"用途" code:@"0"];
    useModel1.filters = @[
        [[CZFilterMenuModel alloc] initWithName:@"住宅" code:@"1"],
        [[CZFilterMenuModel alloc] initWithName:@"别墅" code:@"2"],
        [[CZFilterMenuModel alloc] initWithName:@"写字楼" code:@"3"],
        [[CZFilterMenuModel alloc] initWithName:@"商铺" code:@"4"],
    ];
    
    useModel.filters = @[
        useModel1
    ];
    
    // 价格
    CZFilterMenuModel *priceModel = [[CZFilterMenuModel alloc] initWithName:@"价格"];
    CZFilterMenuModel *priceModel1 = [[CZFilterMenuModel alloc] initWithName:@"总价(万元)" code:@"0"];
    priceModel1.filters = @[
        [[CZFilterMenuModel alloc] initWithName:@"150万元" code:@"1"],
        [[CZFilterMenuModel alloc] initWithName:@"150-200万" code:@"2"],
        [[CZFilterMenuModel alloc] initWithName:@"200-250万" code:@"3"],
        [[CZFilterMenuModel alloc] initWithName:@"250-300万" code:@"4"],
        [[CZFilterMenuModel alloc] initWithName:@"300-400万" code:@"5"],
        [[CZFilterMenuModel alloc] initWithName:@"400-500万" code:@"6"]
    ];
    
    CZFilterMenuModel *priceModel2 = [[CZFilterMenuModel alloc] initWithName:@"单价(元/㎡)" code:@"0"];
    priceModel2.filters = @[
        [[CZFilterMenuModel alloc] initWithName:@"15000元以下" code:@"1"],
        [[CZFilterMenuModel alloc] initWithName:@"15000-20000元" code:@"2"],
        [[CZFilterMenuModel alloc] initWithName:@"20000-25000元" code:@"3"],
        [[CZFilterMenuModel alloc] initWithName:@"25000-30000元" code:@"4"]
    ];
    
    priceModel.filters = @[priceModel1];
    
    // 排序
    CZFilterMenuModel *orderModel = [[CZFilterMenuModel alloc] initWithName:@"排序"];
    orderModel.filters = @[
        [[CZFilterMenuModel alloc] initWithName:@"不限" code:@"0"],
        [[CZFilterMenuModel alloc] initWithName:@"小区年代从近到远" code:@"1"],
        [[CZFilterMenuModel alloc] initWithName:@"小区年代从远到近" code:@"2"],
        [[CZFilterMenuModel alloc] initWithName:@"住宅均价从高到低" code:@"3"],
        [[CZFilterMenuModel alloc] initWithName:@"住宅均价从低到高" code:@"4"]
    ];
    
    self.dictArr = @[areaModel, useModel, priceModel, orderModel];
    [menuView reloadMenuView];
}

#pragma mark - CZFilterMenuViewDetaSource
// tab count
- (NSInteger)numberOfTabInMenuView:(CZFilterMenuView *)menuView {
    return self.dictArr.count;
}

// tab 文字
- (NSString *)menuView:(CZFilterMenuView *)menuView titleAtTabIndex:(NSInteger)tabIndex {
    CZFilterMenuModel *model = self.dictArr[tabIndex];
    return model.name;
}

// 需要展示collectionView还是tableView
- (CZFilterMenuDownType)menuView:(CZFilterMenuView *)menuView typeAtTabIndex:(NSInteger)tabIndex {
    if (tabIndex == 2 || tabIndex == 1) {
        return CZFilterMenuDownTypeItem;
    }
    return CZFilterMenuDownTypeList;
}

// 是否需要底部确定按钮
- (CZFilterMenuConfirmType)menuView:(CZFilterMenuView *)menuView confirmTypeAtTabIndex:(NSInteger)tabIndex {
    if (tabIndex == 0 || tabIndex == 1 || tabIndex == 2) {
        return CZFilterMenuConfirmTypeBottomConfirm;
    }
    return CZFilterMenuConfirmTypeSpeedConfirm;
}

// 第一列,大于0 则至少为一级列表
- (NSInteger)menuView:(CZFilterMenuView *)menuView numberOfFRowsInTab:(NSInteger)tab {
    CZFilterMenuModel *model = self.dictArr[tab];
    return model.filters.count;
}

// 第一列, row 文字
- (NSString *)menuView:(CZFilterMenuView *)menuView titleForFRowsAtIndexPath:(nonnull CZFilterIndexPath *)indexPath {
    CZFilterMenuModel *tabModel = self.dictArr[indexPath.tab];
    CZFilterMenuModel *fRowModel = tabModel.filters[indexPath.fRow];
    return fRowModel.name;
}

// 第二列,大于0 则至少为二级列表
- (NSInteger)menuView:(CZFilterMenuView *)menuView numberOfSRowsInFRow:(NSInteger)fRow tab:(NSInteger)tab {
    CZFilterMenuModel *tabModel = self.dictArr[tab];
    CZFilterMenuModel *fRowModel = tabModel.filters[fRow];
    return fRowModel.filters.count;
}

// 第二列, row 文字
- (NSString *)menuView:(CZFilterMenuView *)menuView titleForSRowsAtIndexPath:(nonnull CZFilterIndexPath *)indexPath {
    CZFilterMenuModel *tabModel = self.dictArr[indexPath.tab];
    CZFilterMenuModel *fRowModel = tabModel.filters[indexPath.fRow];
    CZFilterMenuModel *sRowModel = fRowModel.filters[indexPath.sRow];
    return sRowModel.name;
}

// 第二列,大于0 则三级列表
- (NSInteger)menuView:(CZFilterMenuView *)menuView numberOfTRowsInSRow:(NSInteger)sRow fRow:(NSInteger)fRow tab:(NSInteger)tab {
    CZFilterMenuModel *tabModel = self.dictArr[tab];
    CZFilterMenuModel *fRowModel = tabModel.filters[fRow];
    CZFilterMenuModel *sRowModel = fRowModel.filters[sRow];
    return sRowModel.filters.count;
}

// 第三列, row 文字
- (NSString *)menuView:(CZFilterMenuView *)menuView titleForTRowsAtIndexPath:(nonnull CZFilterIndexPath *)indexPath {
    CZFilterMenuModel *tabModel = self.dictArr[indexPath.tab];
    CZFilterMenuModel *fRowModel = tabModel.filters[indexPath.fRow];
    CZFilterMenuModel *sRowModel = fRowModel.filters[indexPath.sRow];
    CZFilterMenuModel *tRowModel = sRowModel.filters[indexPath.tRow];
    return tRowModel.name;
}

- (BOOL)menuView:(CZFilterMenuView *)menuView mutiSelectedAtIndexPath:(nonnull CZFilterIndexPath *)indexPath {
    if (indexPath.tab == 1) {
        return YES;
    }
    return NO;
}

- (CGFloat)menuView:(CZFilterMenuView *)menuView heightForFooterAtIndexPath:(nonnull CZFilterIndexPath *)indexPath {
    if (indexPath.tab == 2 && indexPath.fRow == 0) {
        return 60;
    }
    return CGFLOAT_MIN;
}

- (NSArray<NSString *> *)menuView:(CZFilterMenuView *)menuView placeholdersAtIndexPath:(CZFilterIndexPath *)indexPath {
    return @[@"最低总价", @"最高总价", @"万"];
}

// 点击回调,根据indexPath自己去处理业务需求
- (void)menuView:(CZFilterMenuView *)menuView didSelectedMenuAtIndexPath:(CZFilterIndexPath *)indexPath {
    NSLog(@"%@-%@-%@-%@", @(indexPath.tab), @(indexPath.fRow), @(indexPath.sRow), @(indexPath.tRow));
}

- (void)menuView:(CZFilterMenuView *)menuView clearFilterConditionAtTabIndex:(NSInteger)tabIndex {
    
}

- (void)menuView:(CZFilterMenuView *)menuView inputTexts:(NSArray<NSString *> *)inputTexts indexPath:(CZFilterIndexPath *)indexPath {
    if (indexPath.tab == 2 && indexPath.fRow == 0) {
        NSLog(@"%@", inputTexts);
        self.inputTexts = [NSString stringWithFormat:@"%@-%@万", inputTexts[0], inputTexts[1]];
    }
}
@end
