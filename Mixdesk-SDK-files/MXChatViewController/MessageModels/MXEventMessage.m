//
//  MXEventMessage.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 15/11/9.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MXEventMessage.h"
#import "MXBundleUtil.h"

@interface MXEventMessage()

@property (nonatomic, strong) NSDictionary *tipStringMap;

@end

@implementation MXEventMessage

- (instancetype)initWithEventContent:(NSString *)eventContent
                           eventType:(MXChatEventType)eventType
{
    if (self = [super init]) {
        self.content    = eventContent;
        self.eventType  = eventType;
    }
    return self;
}

- (NSString *)tipString {
    return [self tipStringMap][@(self.eventType)];
}

- (NSDictionary *)tipStringMap {
    if (!_tipStringMap) {
        _tipStringMap = @{
                @(MXChatEventTypeAgentDidCloseConversation):@"",
                @(MXChatEventTypeWithdrawMsg):@"",
                @(MXChatEventTypeEndConversationTimeout):@"",
                @(MXChatEventTypeRedirect):[NSString stringWithFormat:[MXBundleUtil localizedStringForKey:@"mx_direct_content"], self.userName],
                @(MXChatEventTypeClientEvaluation):@"",
                @(MXChatEventTypeInviteEvaluation):@"",
                @(MXChatEventTypeAgentUpdate):@"",
                @(MXChatEventTypeBackList):[MXBundleUtil localizedStringForKey:@"message_tips_online_failed_listed_in_black_list"],
                @(MXChatEventTypeManualInjectConv):[NSString stringWithFormat:[MXBundleUtil localizedStringForKey:@"mx_direct_content"], self.userName],
                @(MXChatEventTypeAutomationRedirect):[NSString stringWithFormat:[MXBundleUtil localizedStringForKey:@"mx_direct_content"], self.userName],
                @(MXChatEventTypeAutomationAssign):[NSString stringWithFormat:[MXBundleUtil localizedStringForKey:@"mx_direct_content"], self.userName],
                @(MXChatEventTypeAiAutomationRedirect):[NSString stringWithFormat:[MXBundleUtil localizedStringForKey:@"mx_direct_content"], self.userName],
                @(MXChatEventTypeAiAutomationAssign):[NSString stringWithFormat:[MXBundleUtil localizedStringForKey:@"mx_direct_content"], self.userName]
                };
    }
    
    return _tipStringMap;
}

@end
