//
//  CZBottomConfirmView.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/28.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZBottomConfirmView.h"
#import "CZFilterMenuHelper.h"

@implementation CZBottomConfirmView
+ (instancetype)confirmView {
    NSBundle *bundle = [CZFilterMenuHelper libBundle];
    return [[bundle loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.confirmButton.layer.cornerRadius = 3;
    self.confirmButton.layer.masksToBounds = YES;
}
@end
