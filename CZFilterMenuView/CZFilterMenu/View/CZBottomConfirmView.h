//
//  CZBottomConfirmView.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/10/28.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZBottomConfirmView : UIView
@property (weak, nonatomic) IBOutlet UIView *resetView;
@property (weak, nonatomic) IBOutlet UILabel *resetLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@end

NS_ASSUME_NONNULL_END
