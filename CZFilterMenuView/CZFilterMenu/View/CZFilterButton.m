//
//  CZFilterButton.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/28.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterButton.h"

@implementation CZFilterButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat labelWidth = self.titleLabel.intrinsicContentSize.width;

    if (imageWith + labelWidth > self.frame.size.width) {
        CGRect frame =  self.titleLabel.frame;
        frame.size.width = self.frame.size.width - imageWith;
        frame.origin.x = 0;
        self.titleLabel.frame = frame;
        
        CGRect imageViewFrame = self.imageView.frame;
        imageViewFrame.origin.x = frame.size.width;
        self.imageView.frame = imageViewFrame;
        
        [self layoutIfNeeded];
    }
    
}
@end
