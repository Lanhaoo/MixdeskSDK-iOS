//
//  MXEventMessage.h
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 15/11/9.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MXBaseMessage.h"
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
  MXChatEventTypeInitConversation = 0,          // 初始化对话 (init_conv)
  MXChatEventTypeAgentDidCloseConversation = 1, // 客服结束对话 (end_conv_agent)
  MXChatEventTypeEndConversationTimeout =
      2, // 对话超时，系统自动结束对话 (end_conv_timeout)
  MXChatEventTypeRedirect = 3,       // 联系人被转接 (agent_redirect)
  MXChatEventTypeAgentInputting = 4, // 客服正在输入 (agent_inputting)
  MXChatEventTypeInviteEvaluation = 5, // 收到客服邀请评价 (invite_evaluation)
  MXChatEventTypeClientEvaluation = 6,           // 联系人评价的结果
  MXChatEventTypeAgentUpdate = 7,                // 客服的状态发生改变
  MXChatEventTypeBackList = 8,                  // 被添加到黑名单
  MXChatEventTypeWithdrawMsg = 9,               // 消息撤回
  MXChatEventTypeRedirectFail = 10,              // 转人工失败

  MXChatEventTypeManualInjectConv = 11,          // 手动接入对话
  MXChatEventTypeAutomationRedirect = 12,        // automation 相关转接
  MXChatEventTypeAutomationAssign = 13,          // automation 相关转接
  MXChatEventTypeAiAutomationRedirect = 14,      // ai automation 相关转接
  MXChatEventTypeAiAutomationAssign = 15,        // ai automation 相关转接
  MXChatEventTypeAutomationEndConversation = 16, // automation 结束对话

  MXChatEventTypeAgentToClientMsgDelivered = 17, // 客服收到消息
  MXChatEventTypeAgentToClientMsgRead = 18,      // 客服已读消息
} MXChatEventType;

@interface MXEventMessage : MXBaseMessage

/** 事件content */
@property(nonatomic, copy) NSString *content;

/** 事件类型 */
@property(nonatomic, assign) MXChatEventType eventType;

@property(nonatomic, strong, readonly) NSString *tipString;

@property(nonatomic, strong) NSArray *cardData; // 卡片数据

// 存放任意值 extraInfo
@property(nonatomic, strong) NSDictionary *extraInfo;
/**
 * 初始化message
 */
- (instancetype)initWithEventContent:(NSString *)eventContent
                           eventType:(MXChatEventType)eventType;

@end
