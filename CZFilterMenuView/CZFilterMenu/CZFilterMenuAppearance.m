//
//  CZFilterMenuConfiguration.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/27.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterMenuAppearance.h"
#import "CZFilterMenuHelper.h"

@implementation CZFilterMenuAppearance
- (instancetype)init {
    if (self = [super init]) {
        _contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
        _padding = 5.0;
        _titleFontSize = 15.0;
        _cellFontSize = 15.0;
        _itemHeaderFontSize = 20.0;
        _itemCellFontSize = 13.0;
        _cutomFirstTableViewWidthWhenMuti = 76.0;
        _cutomSecondTableViewWidthWhenMuti = 120.0;
        _textColor = [UIColor blackColor];
        _tintColor = [UIColor redColor];
        _backgroundColor = [UIColor lightGrayColor];
        _backgroundTintColor = [UIColor whiteColor];
    }
    return self;
}


@end
