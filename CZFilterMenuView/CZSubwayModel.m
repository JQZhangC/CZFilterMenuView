//
//  CZSubwayModel.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZSubwayModel.h"
#import "MJExtension/MJExtension.h"
@implementation CZSubwayModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"stationList": [CZStationModel class]
    };
}
@end
