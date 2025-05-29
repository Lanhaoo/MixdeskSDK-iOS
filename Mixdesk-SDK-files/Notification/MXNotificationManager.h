//
//  MXNotificationManager.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/5/30.
//  Copyright © 2022 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 点击了群发送消息
 */
#define MX_CLICK_GROUP_NOTIFICATION @"MX_CLICK_GROUP_NOTIFICATION"

@interface MXNotificationManager : NSObject

/**
 *  点击群发消息的回调处理是否需要自己处理  默认NO,跳转到客服页面发起会话
 */
@property (nonatomic, assign) BOOL handleNotification;

+ (MXNotificationManager *)sharedManager;

- (void)openMXGroupNotificationServer;

@end
