//
//  MXHybridMessage.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXBaseMessage.h"

@interface MXHybridMessage : MXBaseMessage

@property (nonatomic, copy)NSString *thumbnail;
@property (nonatomic, copy)NSString *summary;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, strong) NSArray *tags;
@property(nonatomic, strong) NSArray *feedbackBtns;
@property(nonatomic, strong) NSArray *quickBtns;
@property(nonatomic, assign) BOOL hideAvatar; // 是否隐藏头像

- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 * 解析反馈按钮数据
 * @param dictionary 包含反馈按钮数据的字典
 */
- (void)parseFeedbackButtonsFromDictionary:(NSDictionary *)dictionary;

@end


@interface MXFeedbackButtonModel : NSObject

/** 快捷按钮的名称 */
@property(nonatomic, copy) NSString *content;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end