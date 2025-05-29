//
//  MXPreChatData.h
//  MixdeskSDK
//
//  Created by ian luo on 16/7/6.
//  Copyright © 2016年 Mixdesk Inc. All rights reserved.
//

#import "MXModel.h"

@class MXPreChatMenu,MXPreChatMenuItem,MXPreChatForm,MXPreChatFormItem;

extern NSString *const kCaptchaToken;
extern NSString *const kCaptchaValue;

typedef NS_ENUM(NSUInteger, MXPreChatFormItemInputType) {
    MXPreChatFormItemInputTypeSingleSelection,
    MXPreChatFormItemInputTypeMultipleSelection,
    MXPreChatFormItemInputTypeSingleLineText,
    MXPreChatFormItemInputTypeSingleLineNumberText,
    MXPreChatFormItemInputTypeSingleLineDateText,
    MXPreCHatFormItemInputTypeMultipleLineText,
    MXPreChatFormItemInputTypeCaptcha,
};

@interface MXPreChatData : MXModel

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSNumber *isUseCapcha;
@property (nonatomic, strong) NSNumber *hasSubmittedForm;
@property (nonatomic, strong) MXPreChatMenu *menu;
@property (nonatomic, strong) MXPreChatForm *form;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSString *title;

@end

@interface MXPreChatMenu : MXModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NSArray *menuItems;

@end

@interface MXPreChatMenuItem : MXModel

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *targetKind;
@property (nonatomic, copy) NSString *target;

@end

@interface MXPreChatForm : MXModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) NSArray *formItems;

@end

@interface MXPreChatFormItem : MXModel

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *filedName;
@property (nonatomic, assign) MXPreChatFormItemInputType type;
@property (nonatomic, strong) NSNumber *isOptional;
@property (nonatomic, strong) NSArray *choices;
@property (nonatomic, strong) NSNumber *isIgnoreReturnCustomer;

@end
