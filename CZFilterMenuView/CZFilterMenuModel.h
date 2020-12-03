//
//  CZFilterMenuModel.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/28.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZFilterMenuModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) NSArray<CZFilterMenuModel *> *filters;

- (instancetype)initWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name code:(nullable NSString *)code;

- (instancetype)initWithName:(NSString *)name code:(nullable NSString *)code filters:(nullable NSArray<CZFilterMenuModel *> *)filters;
@end

NS_ASSUME_NONNULL_END
