//
//  MCTabInputContentView.h
//  Mixdesk
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXInputContentView.h"
#import "MIXDESK_HPGrowingTextView.h"

@interface MXTabInputContentView : MXInputContentView <UITextFieldDelegate>

@property (strong, nonatomic) MIXDESK_HPGrowingTextView *textField;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupButtons;

@end
