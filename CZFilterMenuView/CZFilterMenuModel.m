//
//  CZFilterMenuModel.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/28.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterMenuModel.h"
@implementation CZFilterMenuModel

- (instancetype)initWithName:(NSString *)name code:(nullable NSString *)code filters:(nullable NSArray<CZFilterMenuModel *> *)filters {
    CZFilterMenuModel *model = [[CZFilterMenuModel alloc] init];
    model.name = name;
    model.code = code;
    model.filters = filters;
    return model;
}

- (instancetype)initWithName:(NSString *)name code:(nullable NSString *)code {
    return [self initWithName:name code:code filters:nil];
}

- (instancetype)initWithName:(NSString *)name {
   return [self initWithName:name code:nil filters:nil];
}
@end
