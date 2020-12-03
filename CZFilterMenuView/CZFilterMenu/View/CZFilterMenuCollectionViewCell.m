//
//  CZFilterMenuCollectionViewCell.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/28.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterMenuCollectionViewCell.h"

@implementation CZFilterMenuCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.layer.cornerRadius = 3;
    self.contentView.layer.masksToBounds = YES;
}

@end
