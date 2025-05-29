//
//  MXPreChatCells.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/7/7.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+MXLayout.h"
#import "NSArray+MXFunctional.h"
#import <MixdeskSDK/MixdeskSDK.h>

#define TextFieldLimit 100

@interface MXPrechatSingleLineTextCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, copy) void(^valueChangedAction)(NSString *);
@property (nonatomic, strong) UITextField *textField;

@end


#pragma mark -

@interface MXPreChatMultiLineTextCell : UITableViewCell

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, copy) void(^heightChanged)(CGFloat);

@end

#pragma mark -

@interface MXPreChatSelectionCell : UITableViewCell

@end

#pragma mark -

@interface MXPreChatCaptchaCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *refreshCapchaButton;
@property (nonatomic, copy) void(^valueChangedAction)(NSString *);
@property (nonatomic, copy) void(^loadCaptchaAction)(UIButton *);

@end

#pragma mark -

@interface MXPreChatSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) MXPreChatFormItem *formItem;
@property (nonatomic, strong) UILabel *titelLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *isOptionalLabel;
@property (nonatomic, assign) BOOL shouldMark;

- (void)setStatus:(BOOL)isReady;

@end

#pragma mark -


