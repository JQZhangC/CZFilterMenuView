//
//  CZFilterMenuCollectionFooterInputView.m
//  CZFilterMenuView
//
//  Created by CZ on 2020/11/2.
//  Copyright © 2020 CZ. All rights reserved.
//

#import "CZFilterMenuCollectionFooterInputView.h"

@interface CZFilterMenuCollectionFooterInputView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;
@end

@implementation CZFilterMenuCollectionFooterInputView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lineViewHeight.constant = 1.0/[UIScreen mainScreen].scale;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textfieldChange:(NSNotification *)noti {
    
    UITextField *textfield = (UITextField *)noti.object;
    
    if (textfield != self.leftTextfield && textfield != self.rightTextfield) {
        return;
    }
    
    NSString *leftString = self.leftTextfield.text;
    NSString *rightString = self.rightTextfield.text;
    if (leftString.length == 0) {
        leftString = @"";
    }
    
    if (rightString.length == 0) {
        rightString = @"";
    }
    
    if (self.textChangeHandler) {
        self.textChangeHandler(@[leftString, rightString]);
    }
}

@end
