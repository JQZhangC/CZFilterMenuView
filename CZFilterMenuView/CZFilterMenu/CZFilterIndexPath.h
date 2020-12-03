//
//  CZFilterIndexPath.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZFilterIndexPath : NSObject <NSCopying>

/// 菜单栏tab index
@property (nonatomic, assign) NSInteger tab;
/// 一级列表 index
@property (nonatomic, assign) NSInteger fRow;
/// 二级列表 index
@property (nonatomic, assign) NSInteger sRow;
/// 三级列表 index
@property (nonatomic, assign) NSInteger tRow;

- (instancetype)initWithTab:(NSInteger)tab;

- (instancetype)initWithTab:(NSInteger)tab fRow:(NSInteger)fRow;

- (instancetype)initWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow;

- (instancetype)initWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow tRow:(NSInteger)tRow;

+ (instancetype)indexPathWithTab:(NSInteger)tab;

+ (instancetype)indexPathWithTab:(NSInteger)tab fRow:(NSInteger)fRow;

+ (instancetype)indexPathWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow;

+ (instancetype)indexPathWithTab:(NSInteger)tab fRow:(NSInteger)fRow sRow:(NSInteger)sRow tRow:(NSInteger)tRow;

@end

NS_ASSUME_NONNULL_END
