//
//  MXCustomizedUIText.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/4/26.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MXUITextKey) {
    
    MXUITextKeyMessageInputPlaceholder,
    MXUITextKeyMessageNoMoreMessage,
    MXUITextKeyMessageNewMessaegArrived,
    MXUITextKeyMessageConfirmResend,
    MXUITextKeyMessageRefreshFail,
    MXUITextKeyMessageLoadHistoryMessageFail,
    
    MXUITextKeyRecordButtonBegin,
    MXUITextKeyRecordButtonEnd,
    MXUITextKeyRecordButtonCancel,
    MXUITextKeyRecordDurationTooShort,
    MXUITextKeyRecordSwipeUpToCancel,
    MXUITextKeyRecordReleaseToCancel,
    MXUITextKeyRecordFail,
    
    MXUITextKeyImageSelectFromImageRoll,
    MXUITextKeyImageSelectCamera,
    MXUITextKeyImageSaveFail,
    MXUITextKeyImageSaveComplete,
    MXUITextKeyImageSave,
    
    MXUITextKeyTextCopy,
    MXUITextKeyTextCopied,
    
    MXUITextKeyNetworkTrafficJam,
    MXUITextKeyDefaultAssistantName,
    
    MXUITextKeyNoAgentTitle,
    MXUITextKeySchedulingAgent,
    MXUITextKeyNoAgentTip,
    
    MXUITextKeyContactMakeCall,
    MXUITextKeyContactSendSMS,
    MXUITextKeyContactSendEmail,
    
    MXUITextKeyOpenLinkWithSafari,
    
    MXUITextKeyRequestEvaluation,
    MXUITextKeyRequestRedirectAgent,
    
    MXUITextKeyFileDownloadOverdue,
    MXUITextKeyFileDownloadCancel,
    MXUITextKeyFileDownloadDownloading,
    MXUITextKeyFileDownloadComplete,
    MXUITextKeyFileDownloadFail,
    
    MXUITextKeyBlacklistMessageRejected,
    MXUITextKeyBlacklistListedInBlacklist,
    
    MXUITextKeyClientIsOnlining,
    MXUITextKeySendTooFast,
    
    //询前表单
    MXUITextKeyPreChatListTitle,
    MXUITextKeyPreChatFormTitle,
    MXUITextKeyPreChatFormMultipleSelectionLabel,
    MXUITextKeyPreChatFormBlankAlertLabel,
    
    //pull refresh
    MXUITextKeyPullRefreshNormal,
    MXUITextKeyPullRfreshTriggered,

    MXUITextKeyEvaluationPleaseSelectLevel,
    MXUITextKeyEvaluationPleaseSelectTag,
};

@interface MXCustomizedUIText : NSObject

///自定义 UI 中的文案
+ (void)setCustomiedTextForKey:(MXUITextKey)key text:(NSString *)string;

+ (void)reset;

+ (NSString *)customiedTextForBundleKey:(NSString *)bundleKey;

@end
