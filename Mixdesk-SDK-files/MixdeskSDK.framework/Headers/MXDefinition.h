//
//  MXDefinition.h
//  MixdeskSDK
//
//  Created by dingnan on 15/10/27.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

#define stringify(arg) (@"" #arg)
#define recordError(e)                                                         \
  { [MXDataCache sharedCache].globalError = e; }

typedef NS_ENUM(NSUInteger, MXState) {
  MXStateUninitialized,
  MXStateInitialized,
  MXStateOffline, // not using
  MXStateUnallocatedAgent,
  MXStateAllocatingAgent, // 正在分配客服
  MXStateAllocatedAgent,
  MXStateBlacklisted
};
typedef void (^StateChangeBlock)(MXState oldState, MXState newState,
                                 NSDictionary *value, NSError *error);

/**
 *  Mixdesk客服系统当前有新消息，开发者可实现该协议方法，通过此方法显示小红点未读标识
 */
#define MX_RECEIVED_NEW_MESSAGES_NOTIFICATION                                  \
  @"MX_RECEIVED_NEW_MESSAGES_NOTIFICATION"

/**
 *  收到该通知，即表示Mixdesk的通信接口出错，通信连接断开
 */

#define MX_COMMUNICATION_FAILED_NOTIFICATION                                   \
  @"MX_COMMUNICATION_FAILED_NOTIFICATION"

/**
 *  收到该通知，即表示联系人成功上线Mixdesk系统
 */
#define MX_CLIENT_ONLINE_SUCCESS_NOTIFICATION                                  \
  @"MX_CLIENT_ONLINE_SUCCESS_NOTIFICATION"

/**
 *  Mixdesk的错误码
 */
#define MXRequesetErrorDomain @"com.mixdesk.error.resquest.error"

/**
 当连接的状态改变时发送的通知
 */
#define MX_NOTIFICATION_SOCKET_STATUS_CHANGE                                   \
  @"MX_NOTIFICATION_SOCKET_STATUS_CHANGE"
#define SOCKET_STATUS_CONNECTED @"SOCKET_STATUS_CONNECTED"
#define SOCKET_STATUS_DISCONNECTED @"SOCKET_STATUS_DISCONNECTED"

/**
 聊天窗口出现
 */
#define MX_NOTIFICATION_CHAT_BEGIN @"MX_NOTIFICATION_CHAT_BEGIN"

/**
 聊天窗口消失
 */
#define MX_NOTIFICATION_CHAT_END @"MX_NOTIFICATION_CHAT_END"

/**
 MixdeskError的code对应码
 */
typedef enum : NSInteger {
  MXErrorCodeParameterUnKnown = -2000, // 未知错误
  MXErrorCodeParameterError = -2001,   // 参数错误
  MXErrorCodeCurrentClientNotFound =
      -2003, // 当前没有联系人，请新建一个联系人后再上线
  MXErrorCodeClientNotExisted = -2004, // Mixdesk服务端没有找到对应的client
  MXErrorCodeConversationNotFound = -2005, // Mixdesk服务端没有找到该对话
  MXErrorCodePlistConfigurationError =
      -2006, // 开发者App的info.plist没有增加NSExceptionDomains，请参考https://github.com/Mixdesk/Mixdesk-SDK-iOS-Demo#info.plist设置
  MXErrorCodeBlacklisted = -2007, // 被加入黑名单，发消息和分配对话都会失败
  MXErrorCodeSchedulerFail = -2008,   // 分配对话失败
  MXErrorCodeUninitailized = -2009,   // 未初始化操作
  MXErrorCodeInitializFailed = -2010, // 初始化失败
} MXErrorCode;

/**
 联系人上线的结果枚举类型
 */
typedef enum : NSUInteger {
  MXClientOnlineResultSuccess = 0,       // 上线成功
  MXClientOnlineResultParameterError,    // 上线参数错误
  MXClientOnlineResultNotScheduledAgent, // 没有可接待的客服
  MXClientOnlineResultBlacklisted,
} MXClientOnlineResult;

/**
 联系人对客服的某次对话的评价
 */
typedef enum : NSUInteger {
  MXConversationEvaluationNegative = 0, // 差评
  MXConversationEvaluationModerate = 1, // 中评
  MXConversationEvaluationPositive = 2  // 好评
} MXConversationEvaluation;

/**
 sdk的接入渠道
 */
typedef enum : NSUInteger {
  MXSDKSourceChannelSDK = 0,  // 原生sdk
  MXSDKSourceChannelAPICloud, // APICloud
  MXSDKSourceChannelDCloud,   // DCloud
  MXSDKSourceChannelFlutter   // Flutter
} MXSDKSourceChannel;
