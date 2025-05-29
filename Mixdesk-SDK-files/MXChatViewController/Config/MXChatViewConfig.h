//
//  MXChatViewConfig.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MXChatViewStyle.h"
#import "MXChatAudioTypes.h"

//是否引入MixdeskSDK
#define INCLUDE_MIXDESK_SDK

/** 关闭键盘的通知 */
extern NSString * const MXChatViewKeyboardResignFirstResponderNotification;
/** 中断audio player的通知 */
extern NSString * const MXAudioPlayerDidInterruptNotification;
/** 刷新TableView的通知 */
extern NSString * const MXChatTableViewShouldRefresh;

/**
 客服的状态
 */
typedef enum : NSUInteger {
    MXChatAgentStatusNone           = 0,   //不显示
    MXChatAgentStatusOnDuty         = 1,            //客服在线
    MXChatAgentStatusOffDuty        = 2,            //客服隐身
    MXChatAgentStatusOffLine        = 3             //客服离线
} MXChatAgentStatus;

/*
 显示聊天窗口的动画
 */
typedef NS_ENUM(NSUInteger, MXTransiteAnimationType) {
    MXTransiteAnimationTypeDefault = 0,
    MXTransiteAnimationTypePush
};

/**
 * @brief MXChatViewConfig为客服聊天界面的前置配置，由MXChatViewManager生成，在MXChatViewController内部逻辑消费
 *
 */
@interface MXChatViewConfig : NSObject

@property (nonatomic, strong) MXChatViewStyle *chatViewStyle;

@property (nonatomic, assign) BOOL hidesBottomBarWhenPushed;
//@property (nonatomic, assign) BOOL isCustomizedChatViewFrame;
@property (nonatomic, assign) CGRect chatViewFrame;
@property (nonatomic, assign) CGPoint chatViewControllerPoint;
@property (nonatomic, strong) NSMutableArray *numberRegexs;
@property (nonatomic, strong) NSMutableArray *linkRegexs;
@property (nonatomic, strong) NSMutableArray *emailRegexs;
@property (nonatomic, assign) MXTransiteAnimationType presentingAnimation;

@property (nonatomic, copy) NSString *chatWelcomeText;
@property (nonatomic, copy) NSString *agentName;
@property (nonatomic, copy) NSString *incomingMsgSoundFileName;
@property (nonatomic, copy) NSString *outgoingMsgSoundFileName;
@property (nonatomic, copy) NSString *scheduledAgentId;
@property (nonatomic, copy) NSString *notScheduledAgentId;
@property (nonatomic, copy) NSString *scheduledGroupId;
@property (nonatomic, copy) NSString *customizedId;
@property (nonatomic, copy) NSString *navTitleText;
@property (nonatomic, copy) NSString *localizedLanguageStr;

@property (nonatomic, assign) BOOL enableEventDispaly;
@property (nonatomic, assign) BOOL enableSendVoiceMessage;
@property (nonatomic, assign) BOOL enableSendImageMessage;
@property (nonatomic, assign) BOOL enableSendEmoji;
@property (nonatomic, assign) BOOL enableMessageImageMask;
@property (nonatomic, assign) BOOL enableMessageSound;
@property (nonatomic, assign) BOOL enableTopPullRefresh;
@property (nonatomic, assign) BOOL enableBottomPullRefresh;
@property (nonatomic, assign) BOOL enableChatWelcome;
@property (nonatomic, assign) BOOL enableTopAutoRefresh;
@property (nonatomic, assign) BOOL enableShowNewMessageAlert;
@property (nonatomic, assign) BOOL isPushChatView;
@property (nonatomic, assign) BOOL enableEvaluationButton;
@property (nonatomic, assign) BOOL enableVoiceRecordBlurView;
@property (nonatomic, assign) BOOL updateClientInfoUseOverride;
@property (nonatomic, assign) BOOL enablePhotoLibraryEdit;

@property (nonatomic, strong) UIImage *incomingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *outgoingDefaultAvatarImage;
@property (nonatomic, assign) BOOL shouldUploadOutgoingAvartar;


@property (nonatomic, assign) NSTimeInterval maxVoiceDuration;

///如果应用中有其他地方正在播放声音，比如游戏，需要将此设置为 YES，防止其他声音在录音或者播放完之后无法继续播放
@property (nonatomic, assign) BOOL keepAudioSessionActive;
@property (nonatomic, assign) MXRecordMode recordMode;
@property (nonatomic, assign) MXPlayMode playMode;

@property (nonatomic, strong) NSArray *preSendMessages;

@property (nonatomic, copy) void(^productCardCallBack)(NSString *productUrl);


#pragma 以下配置是MixdeskSDK用户所用到的配置
#ifdef INCLUDE_MIXDESK_SDK
@property (nonatomic, assign) BOOL enableSyncServerMessage;
@property (nonatomic, assign) BOOL enableInitHistoryMessage;
@property (nonatomic, copy  ) NSString *MXClientId;


@property (nonatomic, strong) NSDictionary *clientInfo;


#endif

+ (instancetype)sharedConfig;

/** 将配置设置为默认值 */
- (void)setConfigToDefault;

@end


///以下内容为向下兼容之前的版本
@interface MXChatViewConfig(deprecated)

@property (nonatomic, assign) BOOL enableRoundAvatar;
@property (nonatomic, assign) BOOL enableIncomingAvatar;
@property (nonatomic, assign) BOOL enableOutgoingAvatar;

@property (nonatomic, copy) UIColor *incomingMsgTextColor;
@property (nonatomic, copy) UIColor *incomingBubbleColor;
@property (nonatomic, copy) UIColor *outgoingMsgTextColor;
@property (nonatomic, copy) UIColor *outgoingBubbleColor;
@property (nonatomic, copy) UIColor *eventTextColor;
@property (nonatomic, copy) UIColor *redirectAgentNameColor;
@property (nonatomic, copy) UIColor *navTitleColor;

@property (nonatomic, copy) UIColor *navBarTintColor;
@property (nonatomic, copy) UIColor *navBarColor;
@property (nonatomic, copy) UIColor *pullRefreshColor;

@property (nonatomic, strong) UIImage *incomingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *outgoingDefaultAvatarImage;
@property (nonatomic, strong) UIImage *messageSendFailureImage;
@property (nonatomic, strong) UIImage *photoSenderImage;
@property (nonatomic, strong) UIImage *photoSenderHighlightedImage;
@property (nonatomic, strong) UIImage *voiceSenderImage;
@property (nonatomic, strong) UIImage *voiceSenderHighlightedImage;
@property (nonatomic, strong) UIImage *incomingBubbleImage;
@property (nonatomic, strong) UIImage *outgoingBubbleImage;
@property (nonatomic, strong) UIImage *imageLoadErrorImage;

@property (nonatomic, assign) UIEdgeInsets bubbleImageStretchInsets;

@property (nonatomic, strong) UIButton *navBarLeftButton;
@property (nonatomic, strong) UIButton *navBarRightButton;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) BOOL didSetStatusBarStyle;


@end

