//
//  MXMessage.h
//  MixdeskSDK
//
//  Created by dingnan on 15/10/23.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXAgent.h"
#import "MXCardInfo.h"
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
  MXMessageActionMessage = 0,                   // 普通消息 (message)
  MXMessageActionInitConversation = 1,          // 初始化对话 (init_conv)
  MXMessageActionAgentDidCloseConversation = 2, // 客服结束对话 (end_conv_agent)
  MXMessageActionEndConversationTimeout = 3,    // 对话超时，系统自动结束对话 (end_conv_timeout)
  MXMessageActionRedirect = 4,                  // 联系人被转接 (agent_redirect)
  MXMessageActionAgentInputting = 5,            // 客服正在输入 (agent_inputting)
  MXMessageActionInviteEvaluation = 6,          // 收到客服邀请评价 (invite_evaluation)
  MXMessageActionClientEvaluation = 7,          // 联系人评价的结果 (client_evaluation)
  MXMessageActionAgentUpdate = 8,               // 客服的状态发生了改变
  MXMessageActionListedInBlackList = 9,         // 被客户加入到黑名单
  MXMessageActionRemovedFromBlackList = 10,      // 被客户从黑名单中移除
  MXMessageActionWithdrawMessage = 11,          // 消息撤回(withdraw_msg)
  MXMessageActionAgentSendCard = 12,            // 线索卡片
  MXMessageActionManualInjectConv = 13,         // 客服手动接入对话

  MXMessageActionAutomationRedirect = 14,       // automation 相关转接
  MXMessageActionAutomationAssign = 15,         // automation 相关转接
  MXMessageActionAiAutomationRedirect = 16,     // ai automation 相关转接
  MXMessageActionAiAutomationAssign = 17,       // ai automation 相关转接
  MXMessageActionAutomationEndConversation = 18, // automation 相关结束对话
  MXMessageActionAutomationEvaluation = 19       // automation 相关邀请评价
} MXMessageAction;

typedef enum : NSUInteger {
  MXMessageContentTypeText = 0,     // 文字
  MXMessageContentTypeImage = 1,    // 图片
  MXMessageContentTypeVoice = 2,    // 语音
  MXMessageContentTypeFile = 3,     // 文件传输
  MXMessageContentTypeRichText = 5, // 图文消息
  MXMessageContentTypeCard = 6,     // 卡片消息
  MXMessageContentTypeHybrid = 7,   // 混合消息
  MXMessageContentTypeVideo = 8,    // 视频
} MXMessageContentType;

typedef enum : NSUInteger {
  MXMessageFromTypeClient = 0, // 来自 联系人
  MXMessageFromTypeAgent = 1,  // 来自 客服
  MXMessageFromTypeSystem = 2, // 来自 系统
  MXMessageFromTypeAutomation = 3, // 来自 automation
  MXMessageFromTypeAiAgent = 4, // 来自 aiAgent
} MXMessageFromType;

typedef enum : NSUInteger {
  MXMessageTypeMessage = 0, // 普通消息
  MXMessageTypeWelcome = 1, // 欢迎消息
  MXMessageTypeEnding = 2,  // 结束语
  MXMessageTypeRemark = 3,  // 评价
} MXMessageType;

typedef enum : NSUInteger {
  MXMessageSendStatusSuccess = 0, // 发送成功
  MXMessageSendStatusFailed = 1,  // 发送失败
  MXMessageSendStatusSending = 2  // 发送中
} MXMessageSendStatus;

@interface MXMessage : MXModel <NSCopying>

/** 消息id */
@property(nonatomic, copy) NSString *messageId;

/** 消息内容 */
@property(nonatomic, copy) NSString *content;

/** 消息的状态 */
@property(nonatomic, assign) MXMessageAction action;

/** 内容类型 */
@property(nonatomic, assign) MXMessageContentType contentType;

/** trackId */
@property(nonatomic, copy) NSString *trackId;

/** 客服id */
@property(nonatomic, copy) NSString *agentId;

/** 客服 */
@property(nonatomic, strong) MXAgent *agent;

/** 消息发送人头像 */
@property(nonatomic, copy) NSString *messageAvatar;

/** 消息发送人名字 */
@property(nonatomic, copy) NSString *messageUserName;

/** 消息创建时间, UTC格式 */
@property(nonatomic, copy) NSDate *createdOn;

/** 联系人 || 客服 || 系统 || automation || aiAgent */
@property(nonatomic, assign) MXMessageFromType fromType;

/** 消息类型 */
@property(nonatomic, assign) MXMessageType type;

/** 消息状态 */
@property(nonatomic, assign) MXMessageSendStatus sendStatus;

/** 消息对应的对话id */
@property(nonatomic, copy) NSString *conversationId;

/** 消息是否已读 */
@property(nonatomic, assign) bool isRead;

/** 标记消息是否是敏感消息 */
@property(nonatomic, assign) bool isSensitive;

/** 标记客服发送消息的状态 1 服务器已接收; 2 sdk已接收; 3 sdk已读 */
@property(nonatomic, strong) NSNumber *readStatus;

/*
 该消息对应的 enterprise id,
 不一定有值，也不存数据库，仅用来判断该消息属于哪个企业，用来切换数据库,
 如果这个地方没有值，查看 agent 对象里面的 enterpriseId 字段
 */
@property(nonatomic, copy) NSString *enterpriseId;

/** 不同的 message 类型会携带不同数据，也可能为空, 以JSON格式保存到数据库 */
@property(nonatomic, copy) id accessoryData;

/** 线索卡片数据 */
@property(nonatomic, strong) NSArray *cardData;

/** 消息是否为撤回消息，默认不撤回 */
@property(nonatomic, assign) BOOL isMessageWithDraw;

+ (instancetype)createBlacklistMessageWithAction:(NSString *)action;

- (NSString *)stringFromContentType;

//- (id)initMessageWithData:(NSDictionary *)data;

@end
