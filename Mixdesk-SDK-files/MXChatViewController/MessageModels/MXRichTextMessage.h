//
//  MXRichTextMessage.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXBaseMessage.h"
#include <objc/NSObjCRuntime.h>
#include <objc/NSObject.h>

@interface MXRichTextMessage : MXBaseMessage

@property(nonatomic, copy) NSString *thumbnail;
@property(nonatomic, copy) NSString *summary;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, strong) NSArray *tags;
@property(nonatomic, strong) NSArray *quickBtns;
@property(nonatomic, strong) NSArray *feedbackBtns;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface MXMessageBottomQuickBtnModel : NSObject

/** 快捷按钮的名称 */
@property(nonatomic, copy) NSString *btn_text;
/** 快捷按钮的类型 */
@property(nonatomic, assign) NSInteger btn_type;
/** 快捷按钮的内容 */
@property(nonatomic, copy) NSString *content;
/** 快捷按钮的id */
@property(nonatomic, assign) NSInteger id;
/** 快捷按钮的名称 */
@property(nonatomic, copy) NSObject *style;
/** 快捷按钮的func  */
@property(nonatomic, assign) NSInteger func;
/** 快捷按钮的funcId  */
@property(nonatomic, copy) NSString *func_id;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end