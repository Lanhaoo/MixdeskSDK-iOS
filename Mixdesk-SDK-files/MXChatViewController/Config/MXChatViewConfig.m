//
//  MXChatViewConfig.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXChatViewConfig.h"
#import "MXChatDeviceUtil.h"
#import "MXChatFileUtil.h"
#import "MXAssetUtil.h"
#import "MXBundleUtil.h"

NSString * const MXChatViewKeyboardResignFirstResponderNotification = @"MXChatViewKeyboardResignFirstResponderNotification";
NSString * const MXAudioPlayerDidInterruptNotification = @"MXAudioPlayerDidInterruptNotification";
NSString * const MXChatTableViewShouldRefresh = @"MXChatTableViewShouldRefresh";


@implementation MXChatViewConfig

+ (instancetype)sharedConfig {
    static MXChatViewConfig *_sharedConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfig = [[MXChatViewConfig alloc] init];
    });
    return _sharedConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setConfigToDefault];
    }
    return self;
}

- (void)setConfigToDefault {
    
    self.chatViewStyle = [MXChatViewStyle defaultStyle];
    
    self.hidesBottomBarWhenPushed   = true;
//    self.isCustomizedChatViewFrame  = false;
    self.chatViewFrame              = [MXChatDeviceUtil getDeviceScreenRect];
    self.chatViewControllerPoint    = CGPointMake(0, 0);
    
    self.numberRegexs = [[NSMutableArray alloc] initWithArray:@[@"^(\\d{3,4}-?)\\d{7,8}$", @"^1[3|4|5|7|8]\\d{9}", @"[0-9]\\d{4,10}"]];
    self.linkRegexs   = [[NSMutableArray alloc] initWithArray:@[@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"]];
    self.emailRegexs  = [[NSMutableArray alloc] initWithArray:@[@"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"]];
    
    self.chatWelcomeText        = @"";
    self.agentName              = @"";
    self.chatWelcomeText        = @"";
    self.agentName              = @"";
    self.scheduledAgentId       = nil;
    self.notScheduledAgentId    = nil;
    self.scheduledGroupId       = nil;
    self.customizedId           = @"";
    self.navTitleText           = nil;
    self.localizedLanguageStr   = nil;
    
    self.incomingDefaultAvatarImage     = [MXAssetUtil incomingDefaultAvatarImage];
    _outgoingDefaultAvatarImage     = [MXAssetUtil outgoingDefaultAvatarImage]; //用户可以指定头像，如果指定了头像，在用户上线之后，将头像指定给上线后的用户

    self.enableEventDispaly      = false;
    self.enableSendVoiceMessage  = true;
    self.enableSendImageMessage  = true;
    self.enableSendEmoji         = true;
    self.enableMessageImageMask  = true;
    self.enableMessageSound      = true;
    self.enableTopPullRefresh    = false;
    self.enableBottomPullRefresh = false;
    self.enableVoiceRecordBlurView = false;
    self.shouldUploadOutgoingAvartar = NO;
    self.enablePhotoLibraryEdit  = true;
    
    self.enableChatWelcome         = false;
    self.enableTopAutoRefresh      = true;
    self.isPushChatView            = true;
    self.enableShowNewMessageAlert = true;
    self.enableEvaluationButton    = true;
    self.shouldUploadOutgoingAvartar = NO;
    
    self.maxVoiceDuration               = 60;
    
    self.incomingMsgSoundFileName       = @"MXNewMessageRing.mp3";
    self.outgoingMsgSoundFileName       = @"MXSendMessageRing.mp3";
    
    self.preSendMessages = nil;
    self.productCardCallBack = nil;
    
#pragma 以下配置是MixdeskSDK用户所用到的配置
#ifdef INCLUDE_MIXDESK_SDK
    self.enableSyncServerMessage = true;
    self.enableInitHistoryMessage = YES;
    self.MXClientId             = @"";
    
    self.clientInfo                     = nil;
    
    self.updateClientInfoUseOverride = NO;
    
#endif
}

- (void)setOutgoingDefaultAvatarImage:(UIImage *)outgoingDefaultAvatarImage {
    _outgoingDefaultAvatarImage = outgoingDefaultAvatarImage;
    self.shouldUploadOutgoingAvartar = YES;//如果用户修改了默认头像，标记用户上线之后去更新当前用户头像
}


@end

#pragma mark -

@implementation MXChatViewConfig(deprecated)
@dynamic enableRoundAvatar;
@dynamic enableIncomingAvatar;
@dynamic enableOutgoingAvatar;
@dynamic incomingMsgTextColor;
@dynamic incomingBubbleColor;
@dynamic outgoingMsgTextColor;
@dynamic outgoingBubbleColor;
@dynamic eventTextColor;
@dynamic redirectAgentNameColor;
@dynamic navTitleColor;
@dynamic navBarTintColor;
@dynamic navBarColor;
@dynamic pullRefreshColor;
@dynamic incomingDefaultAvatarImage;
@dynamic outgoingDefaultAvatarImage;
@dynamic messageSendFailureImage;
@dynamic photoSenderImage;
@dynamic photoSenderHighlightedImage;
@dynamic voiceSenderImage;
@dynamic voiceSenderHighlightedImage;
@dynamic incomingBubbleImage;
@dynamic outgoingBubbleImage;
@dynamic imageLoadErrorImage;
@dynamic bubbleImageStretchInsets;
@dynamic navBarLeftButton;
@dynamic navBarRightButton;
@dynamic statusBarStyle;
@dynamic didSetStatusBarStyle;

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.chatViewStyle;
}

@end
