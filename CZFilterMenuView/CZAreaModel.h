//
//  CZAreaModel.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZAreaModel : NSObject

@property (nonatomic, copy) NSString *areaId;
@property (nonatomic, copy) NSString *area;

@property (nonatomic, copy) NSString *searchAreaId;
@property (nonatomic, assign) NSInteger childCount;

@end

NS_ASSUME_NONNULL_END
