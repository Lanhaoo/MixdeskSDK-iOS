//
//  MXCustomizedUIText.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/4/26.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXCustomizedUIText.h"

static NSDictionary * keyTextMap;
static NSMutableDictionary * customizedTextMap;

@implementation MXCustomizedUIText

+ (void)load {
    keyTextMap = @{
        @(MXUITextKeyMessageInputPlaceholder) : @"new_message",
        @(MXUITextKeyMessageNoMoreMessage) : @"no_more_messages",
        @(MXUITextKeyMessageNewMessaegArrived) : @"display_new_message",
        @(MXUITextKeyMessageConfirmResend) : @"retry_send_message",
        @(MXUITextKeyMessageRefreshFail) : @"cannot_refresh",
        @(MXUITextKeyMessageLoadHistoryMessageFail) : @"load_history_message_error",
        
        @(MXUITextKeyRecordButtonBegin) : @"record_speak",
        @(MXUITextKeyRecordButtonEnd) : @"record_end",
        @(MXUITextKeyRecordButtonCancel) : @"cancel",
        @(MXUITextKeyRecordDurationTooShort) : @"recode_time_too_short",
        @(MXUITextKeyRecordSwipeUpToCancel) : @"record_cancel_swipe",
        @(MXUITextKeyRecordReleaseToCancel) : @"record_cancel_realse",
        @(MXUITextKeyRecordFail) : @"record_error",
        
        @(MXUITextKeyImageSelectFromImageRoll) : @"select_gallery",
        @(MXUITextKeyImageSelectCamera) : @"select_camera",
        @(MXUITextKeyImageSaveFail) : @"save_photo_error",
        @(MXUITextKeyImageSaveComplete) : @"save_photo_success",
        @(MXUITextKeyImageSave) : @"save_photo",
        
        @(MXUITextKeyTextCopy) : @"save_text",
        @(MXUITextKeyTextCopied) : @"save_text_success",
        
        @(MXUITextKeyNetworkTrafficJam) : @"network_jam",
        
        @(MXUITextKeyDefaultAssistantName) : @"default_assistant",
        
        @(MXUITextKeyNoAgentTitle) : @"no_agent_title",
        @(MXUITextKeySchedulingAgent) : @"wait_agent",
        @(MXUITextKeyNoAgentTip) : @"no_agent_tips",
        
        @(MXUITextKeyContactMakeCall) : @"make_call_to",
        @(MXUITextKeyContactSendSMS) : @"send_message_to",
        @(MXUITextKeyContactSendEmail) : @"make_email_to",
        
        @(MXUITextKeyOpenLinkWithSafari) : @"open_url_by_safari",
        
        @(MXUITextKeyRequestEvaluation) : @"mixdesk_evaluation_sheet",
        
        @(MXUITextKeyRequestRedirectAgent) : @"mixdesk_redirect_sheet",
        
        @(MXUITextKeyFileDownloadOverdue) : @"file_download_file_is_expired",
        @(MXUITextKeyFileDownloadCancel) : @"file_download_canceld",
        @(MXUITextKeyFileDownloadFail) : @"file_download_failed",
        @(MXUITextKeyFileDownloadDownloading) : @"file_download_downloading",
        @(MXUITextKeyFileDownloadComplete) : @"file_download_complete",
        
        @(MXUITextKeyBlacklistMessageRejected) : @"message_tips_send_message_fail_listed_in_black_list",
        @(MXUITextKeyBlacklistListedInBlacklist) : @"message_tips_online_failed_listed_in_black_list",
        
        @(MXUITextKeyClientIsOnlining) : @"cannot_text_client_is_onlining",
        @(MXUITextKeySendTooFast) : @"send_to_fast",
        
        @(MXUITextKeyPreChatListTitle) : @"pre_chat_list_title",
        @(MXUITextKeyPreChatFormTitle) : @"pre_chat_form_title",
        @(MXUITextKeyPreChatFormMultipleSelectionLabel) : @"pre_chat_form_mutiple_selection_label",
        @(MXUITextKeyPreChatFormBlankAlertLabel) : @"pre_chat_form_black_alert_label",
        
        @(MXUITextKeyPullRefreshNormal) : @"pull_refresh_normal",
        @(MXUITextKeyPullRfreshTriggered) : @"pull_refresh_triggered",
        @(MXUITextKeyEvaluationPleaseSelectLevel) : @"mx_evaluation_please_select_level",
        @(MXUITextKeyEvaluationPleaseSelectTag) : @"mx_evaluation_please_select_tag",
        };
    
    
    customizedTextMap = [NSMutableDictionary new];
}

+ (void)setCustomiedTextForKey:(MXUITextKey)key text:(NSString *)string {
    if (string.length == 0) {
        return;
    }
    
    [customizedTextMap setObject:string forKey:[keyTextMap objectForKey:@(key)]];
}

+ (void)reset {
    [customizedTextMap removeAllObjects];
}

+ (NSString *)customiedTextForBundleKey:(NSString *)bundleKey {
    return [customizedTextMap objectForKey:bundleKey];
}

@end
