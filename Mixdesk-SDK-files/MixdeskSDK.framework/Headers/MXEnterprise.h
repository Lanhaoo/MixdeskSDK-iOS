//
//  MXEnterprise.h
//  MixdeskSDK
//
//  Created by Injoy on 15/10/27.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXPreChatData.h"
#import <Foundation/Foundation.h>

@interface MXEnterpriseConfig : NSObject

/**企业工作台 配置信息*/

@property(nonatomic, copy)
    NSString *evaluationPromtText; /// 客服邀请评价显示的文案

@property(nonatomic, copy) NSString *evaluationProblemFeedback; // 是否显示评价反馈

@property(nonatomic, assign)
    BOOL allow_active_evaluation; /// 是否允许联系人主动评价

// 当前的评价等级
@property (nonatomic, assign) NSUInteger evaluation_type;

@property(nonatomic, copy) NSString *avatar; // 企业客服头像

@property(nonatomic, copy) NSString *public_nickname; //

@property(nonatomic, readonly, assign)
    bool photoMsgStatus; // 是否可以发送image类型消息

@property(nonatomic, readonly, assign)
    bool videoMsgStatus; // 是否可以发送video类型消息

@property(nonatomic, readonly, assign)
    bool hideHistoryConvoStatus; // 是否隐藏历史对话

@property(nonatomic, strong) MXPreChatData *preChatData; // 讯前表单数据模型

@property(nonatomic, assign) BOOL withdraw_msg_show; // 是否显示撤回消息的提示语

@property(nonatomic, assign) BOOL ip_allowed; // 是否地区限制

@end

@interface MXEnterprise : NSObject

/** 企业id */
@property(nonatomic, copy) NSString *enterpriseId;

/** 企业简称 */
@property(nonatomic, copy) NSString *name;

/** 企业全名 */
@property(nonatomic, copy) NSString *fullname;

/** 企业负责人的邮箱 */
@property(nonatomic, copy) NSString *contactEmail;

/** 企业负责人的电话 */
@property(nonatomic, copy) NSString *contactTelephone;

/** 企业负责人的姓名 */
@property(nonatomic, copy) NSString *contactName;

/** 企业联系电话 */
@property(nonatomic, copy) NSString *telephone;

/** 网址 */
@property(nonatomic, copy) NSString *website;

/** 行业 */
@property(nonatomic, copy) NSString *industry;

/** 企业地址 */
@property(nonatomic, copy) NSString *location;

/** 邮寄地址 */
@property(nonatomic, copy) NSString *mailingAddress;

/**企业工作台 配置信息*/
@property(nonatomic, strong) MXEnterpriseConfig *configInfo;

- (void)parseEnterpriseConfigData:(NSDictionary *)json;

- (NSString *)toEnterpriseConfigJsonString;

@end

/**
 * 评价等级配置数组，每项包含：
 * - tags: 标签数组，每个标签包含id和name
 * - is_required: 是否必填
 * - level: 评价等级（0-4，分别对应非常不满意到非常满意）
 * - name: 评价名称
 */


// 评价标签
@interface MXEvaluationTag : NSObject
@property(nonatomic, assign) NSInteger id;
@property(nonatomic, copy) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

// 评价等级配置
@interface MXEvaluationLevel : NSObject
@property(nonatomic, strong) NSArray<MXEvaluationTag *> *tags;
@property(nonatomic, assign) BOOL is_required;
@property(nonatomic, assign) NSInteger level;
@property(nonatomic, copy) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

@interface MXEvaluationConfig : NSObject
@property(nonatomic, strong) NSArray<MXEvaluationLevel *> *level_list;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
