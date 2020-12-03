//
//  CZSubwayModel.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CZStationModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CZSubwayModel : NSObject
@property (nonatomic, assign) NSInteger lineId;
@property (nonatomic, copy) NSString *lineName;
@property (nonatomic, strong) NSArray<CZStationModel *> *stationList;
@end

NS_ASSUME_NONNULL_END
