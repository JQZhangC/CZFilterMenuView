//
//  CZFilterMenuCollectionFooterInputView.h
//  CZFilterMenuView
//
//  Created by CZ on 2020/11/2.
//  Copyright © 2020 CZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZFilterMenuCollectionFooterInputView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *leftTextfield;
@property (weak, nonatomic) IBOutlet UITextField *rightTextfield;

@property (nonatomic, copy) void (^textChangeHandler)(NSArray *inputTexts);
@end

NS_ASSUME_NONNULL_END
