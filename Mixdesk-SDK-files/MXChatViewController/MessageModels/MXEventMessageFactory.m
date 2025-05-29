//
//  MXEventMessageFactory.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXEventMessageFactory.h"
#import "MXEventMessage.h"
#import "MXBundleUtil.h"

@implementation MXEventMessageFactory

- (MXBaseMessage *)createMessage:(MXMessage *)plainMessage {
    NSString *eventContent = @"";
    MXChatEventType eventType = MXChatEventTypeInitConversation;
    switch (plainMessage.action) {
        case MXMessageActionInitConversation:
        {
            eventContent = @"您进入了客服对话";
            eventType = MXChatEventTypeInitConversation;
            break;
        }
        case MXMessageActionAgentDidCloseConversation:
        {
            eventContent = @"客服结束了此条对话";
            eventType = MXChatEventTypeAgentDidCloseConversation;
            break;
        }
        case MXMessageActionEndConversationTimeout:
        {
            eventContent = @"对话超时，系统自动结束了对话";
            eventType = MXChatEventTypeEndConversationTimeout;
            break;
        }
        case MXMessageActionRedirect:
        {
            eventContent = @"您的对话被转接给了其他客服";
            eventType = MXChatEventTypeRedirect;
            break;
        }
        case MXMessageActionAgentInputting:
        {
            eventContent = @"客服正在输入...";
            eventType = MXChatEventTypeAgentInputting;
            break;
        }
        case MXMessageActionInviteEvaluation:
        {
            eventContent = @"客服邀请您评价刚才的服务";
            eventType = MXChatEventTypeInviteEvaluation;
            break;
        }
        case MXMessageActionClientEvaluation:
        {
            eventContent = @"联系人评价结果";
            eventType = MXChatEventTypeClientEvaluation;
            break;
        }
        case MXMessageActionAgentUpdate:
        {
            eventContent = @"客服状态发生改变";
            eventType = MXChatEventTypeAgentUpdate;
            break;
        }
        case MXMessageActionListedInBlackList:
        {
            eventContent = [MXBundleUtil localizedStringForKey:@"message_tips_online_failed_listed_in_black_list"];
            eventType = MXChatEventTypeAgentUpdate;
            break;
        }
        case MXMessageActionWithdrawMessage:
        {
            eventContent = @"消息撤回";
            eventType = MXChatEventTypeWithdrawMsg;
            break;
        }
        case MXMessageActionManualInjectConv:
        {
            eventContent = @"手动接入对话";
            eventType = MXChatEventTypeManualInjectConv;
            break;
        }
        case MXMessageActionAutomationRedirect:
        {
            eventContent = @"自动化转接";
            eventType = MXChatEventTypeAutomationRedirect;
            break;
        }
        case MXMessageActionAutomationAssign:
        {
            eventContent = @"自动化转接";
            eventType = MXChatEventTypeAutomationAssign;
            break;
        }
        case MXMessageActionAiAutomationRedirect:
        {
            eventContent = @"自动化转接";
            eventType = MXChatEventTypeAiAutomationRedirect;
            break;
        }
        case MXMessageActionAiAutomationAssign:
        {
            eventContent = @"自动化转接";
            eventType = MXChatEventTypeAiAutomationAssign;
            break;
        }
        case MXMessageActionAutomationEndConversation:
        {
            eventContent = @"automation结束对话";
            eventType = MXChatEventTypeAutomationEndConversation;
            break;
        }
        default:
            break;
    }
    if (eventContent.length == 0) {
        return nil;
    }
    MXEventMessage *toMessage = [[MXEventMessage alloc] initWithEventContent:eventContent eventType:eventType];
    toMessage.messageId = plainMessage.messageId;
    toMessage.date = plainMessage.createdOn;
    toMessage.content = eventContent;
    toMessage.userName = plainMessage.agent.nickname;
    toMessage.cardData = plainMessage.cardData;
    toMessage.conversionId = plainMessage.conversationId;
    
    if (plainMessage.action == MXMessageActionListedInBlackList) {
        toMessage.eventType = MXChatEventTypeBackList;
    }
    
    return toMessage;
}

@end
