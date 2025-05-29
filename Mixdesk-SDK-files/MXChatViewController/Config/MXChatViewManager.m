//
//  MXChatViewManager.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/27.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXChatViewManager.h"
#import "MXImageUtil.h"
#import "MXServiceToViewInterface.h"
#import "MXTransitioningAnimation.h"
#import "MXAssetUtil.h"

@interface MXChatViewManager()

@property(nonatomic, strong) MXChatViewController *chatViewController;

@end

@implementation MXChatViewManager  {
    MXChatViewConfig *chatViewConfig;
}

//以下属性将直接转发给 MXChatViewConfig 来管理
@dynamic keepAudioSessionActive;
@dynamic playMode;
@dynamic recordMode;
@dynamic chatViewStyle;
@dynamic preSendMessages;

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return chatViewConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        chatViewConfig = [MXChatViewConfig sharedConfig];
    }
    return self;
}

- (MXChatViewController *)pushMXChatViewControllerInViewController:(UIViewController *)viewController {
    [self presentOnViewController:viewController transiteAnimation:MXTransiteAnimationTypePush];
    return self.chatViewController;
}

- (MXChatViewController *)presentMXChatViewControllerInViewController:(UIViewController *)viewController {
    chatViewConfig.isPushChatView = false;
    
    [self presentOnViewController:viewController transiteAnimation:MXTransiteAnimationTypeDefault];
    return self.chatViewController;
}

- (MXChatViewController *)createMXChatViewController {
    UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:self.chatViewController];
    [self updateNavAttributesWithViewController:self.chatViewController navigationController:(UINavigationController *)viewController defaultNavigationController:nil isPresentModalView:false];
    return (MXChatViewController *)viewController.topViewController;
}

- (void)presentOnViewController:(UIViewController *)rootViewController transiteAnimation:(MXTransiteAnimationType)animation {
    chatViewConfig.presentingAnimation = animation;
    
    UIViewController *viewController = nil;
    if (animation == MXTransiteAnimationTypePush) {
        viewController = [self createNavigationControllerWithWithAnimationSupport:self.chatViewController presentedViewController:rootViewController];
        BOOL shouldUseUIKitAnimation = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [rootViewController presentViewController:viewController animated:shouldUseUIKitAnimation completion:nil];
    } else {
        viewController = [[UINavigationController alloc] initWithRootViewController:self.chatViewController];
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self updateNavAttributesWithViewController:self.chatViewController navigationController:(UINavigationController *)viewController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController presentViewController:viewController animated:YES completion:nil];
    }
}

- (UINavigationController *)createNavigationControllerWithWithAnimationSupport:(MXChatViewController *)rootViewController presentedViewController:(UIViewController *)presentedViewController{
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [navigationController setTransitioningDelegate:[MXTransitioningAnimation transitioningDelegateImpl]];
//        [navigationController setModalPresentationStyle:UIModalPresentationCustom];
    } else {
        [self updateNavAttributesWithViewController:self.chatViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController.view.window.layer addAnimation:[MXTransitioningAnimation createPresentingTransiteAnimation:[MXChatViewConfig sharedConfig].presentingAnimation] forKey:nil];
    }
    return navigationController;
}

//修改导航栏属性
- (void)updateNavAttributesWithViewController:(MXChatViewController *)viewController
                         navigationController:(UINavigationController *)navigationController
                  defaultNavigationController:(UINavigationController *)defaultNavigationController
                           isPresentModalView:(BOOL)isPresentModalView {
    if ([MXChatViewConfig sharedConfig].navBarTintColor) {
        navigationController.navigationBar.tintColor = [MXChatViewConfig sharedConfig].navBarTintColor;
    } else if (defaultNavigationController && defaultNavigationController.navigationBar.tintColor) {
        navigationController.navigationBar.tintColor = defaultNavigationController.navigationBar.tintColor;
    }
    
    if (defaultNavigationController.navigationBar.titleTextAttributes) {
        navigationController.navigationBar.titleTextAttributes = defaultNavigationController.navigationBar.titleTextAttributes;
    } else {
        UIColor *color = [MXChatViewConfig sharedConfig].navTitleColor ?: [[UINavigationBar appearance].titleTextAttributes objectForKey:NSForegroundColorAttributeName] ?: [UIColor blackColor];
        UIFont *font = [MXChatViewConfig sharedConfig].chatViewStyle.navTitleFont ?: [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName] ?: [UIFont systemFontOfSize:16.0];
        NSDictionary *attr = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
        navigationController.navigationBar.titleTextAttributes = attr;
    }
    
    if ([MXChatViewConfig sharedConfig].chatViewStyle.navBarBackgroundImage) {
        if (@available(iOS 15.0, *)) {
            // 常规页面
            UINavigationBarAppearance * appearance = navigationController.navigationBar.standardAppearance;
            // 背景图片
            appearance.backgroundImage = [MXChatViewConfig sharedConfig].chatViewStyle.navBarBackgroundImage;
            // 带scroll滑动的页面
            navigationController.navigationBar.scrollEdgeAppearance = appearance;
        } else {
            [navigationController.navigationBar setBackgroundImage:[MXChatViewConfig sharedConfig].chatViewStyle.navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
        }
    } else if ([MXChatViewConfig sharedConfig].navBarColor) {
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance * appearance = navigationController.navigationBar.standardAppearance;
            // 背景色
            appearance.backgroundColor = [MXChatViewConfig sharedConfig].navBarColor;
            navigationController.navigationBar.scrollEdgeAppearance = appearance;
        } else {
            navigationController.navigationBar.barTintColor = [MXChatViewConfig sharedConfig].navBarColor;
        }
    } else if (defaultNavigationController && defaultNavigationController.navigationBar.barTintColor) {
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance * appearance = navigationController.navigationBar.standardAppearance;
            appearance.backgroundColor = defaultNavigationController.navigationBar.barTintColor;
            navigationController.navigationBar.scrollEdgeAppearance = appearance;
        } else {
            navigationController.navigationBar.barTintColor = defaultNavigationController.navigationBar.barTintColor;
        }
    } else {
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance * appearance = navigationController.navigationBar.standardAppearance;
            navigationController.navigationBar.scrollEdgeAppearance = appearance;
        }
    }
    
    if (isPresentModalView) {
        //导航栏左键
        UIBarButtonItem *customizedBackItem = nil;
        if ([MXChatViewConfig sharedConfig].chatViewStyle.navBackButtonImage) {
//            customizedBackItem = [[UIBarButtonItem alloc]initWithImage:[MXChatViewConfig sharedConfig].chatViewStyle.navBackButtonImage style:(UIBarButtonItemStylePlain) target:viewController action:@selector(dismissChatViewController)];
            //xlp
            customizedBackItem = [[UIBarButtonItem alloc] initWithImage:[[MXChatViewConfig sharedConfig].chatViewStyle.navBackButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissChatViewController)];
        }
        
        if ([MXChatViewConfig sharedConfig].presentingAnimation == MXTransiteAnimationTypeDefault) {
            viewController.navigationItem.leftBarButtonItem = customizedBackItem ?: [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:viewController action:@selector(dismissChatViewController)];
        } else {
            viewController.navigationItem.leftBarButtonItem = customizedBackItem ?: [[UIBarButtonItem alloc] initWithImage:[MXAssetUtil backArrow] style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissChatViewController)];
            
        }
    }
    
    //导航栏右键
    if ([MXChatViewConfig sharedConfig].navBarRightButton) {
        [[MXChatViewConfig sharedConfig].navBarRightButton addTarget:viewController action:@selector(didSelectNavigationRightButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //导航栏标题
    if ([MXChatViewConfig sharedConfig].navTitleText) {
        viewController.navigationItem.title = [MXChatViewConfig sharedConfig].navTitleText;
    }
}

- (void)disappearMXChatViewController {
    if (!_chatViewController) {
        return ;
    }
    [self.chatViewController dismissChatViewController];
}

- (void)hidesBottomBarWhenPushed:(BOOL)hide
{
    chatViewConfig.hidesBottomBarWhenPushed = hide;
}

//- (void)enableCustomChatViewFrame:(BOOL)enable {
//    chatViewConfig.isCustomizedChatViewFrame = enable;
//}

- (void)setChatViewFrame:(CGRect)viewFrame {
    chatViewConfig.chatViewFrame = viewFrame;
}

- (void)setViewControllerPoint:(CGPoint)viewPoint {
    chatViewConfig.chatViewControllerPoint = viewPoint;
}

- (void)setPlayMode:(MXPlayMode)playMode {
    chatViewConfig.playMode = playMode;
}

- (MXPlayMode)playMode {
    return chatViewConfig.playMode;
}

- (void)setMessageNumberRegex:(NSString *)numberRegex {
    if (!numberRegex) {
        return;
    }
    [chatViewConfig.numberRegexs addObject:numberRegex];
}

- (void)setMessageLinkRegex:(NSString *)linkRegex {
    if (!linkRegex) {
        return;
    }
    [chatViewConfig.linkRegexs addObject:linkRegex];
}

- (void)setMessageEmailRegex:(NSString *)emailRegex {
    if (!emailRegex) {
        return;
    }
    [chatViewConfig.emailRegexs addObject:emailRegex];
}

- (void)enableEventDispaly:(BOOL)enable {
    chatViewConfig.enableEventDispaly = enable;
}

- (void)enableSendVoiceMessage:(BOOL)enable {
    chatViewConfig.enableSendVoiceMessage = enable;
}

- (void)enableSendImageMessage:(BOOL)enable {
    chatViewConfig.enableSendImageMessage = enable;
}

- (void)enableSendEmoji:(BOOL)enable {
    chatViewConfig.enableSendEmoji = enable;
}

- (void)enableShowNewMessageAlert:(BOOL)enable {
    chatViewConfig.enableShowNewMessageAlert = enable;
}

- (void)setIncomingMessageTextColor:(UIColor *)textColor {
    if (!textColor) {
        return;
    }
    chatViewConfig.incomingMsgTextColor = [textColor copy];
}

- (void)setIncomingBubbleColor:(UIColor *)bubbleColor {
    if (!bubbleColor) {
        return;
    }
    chatViewConfig.incomingBubbleColor = bubbleColor;
}

- (void)setOutgoingMessageTextColor:(UIColor *)textColor {
    if (!textColor) {
        return;
    }
    chatViewConfig.outgoingMsgTextColor = [textColor copy];
}

- (void)setOutgoingBubbleColor:(UIColor *)bubbleColor {
    if (!bubbleColor) {
        return;
    }
    chatViewConfig.outgoingBubbleColor = bubbleColor;
}

- (void)enableMessageImageMask:(BOOL)enable
{
    chatViewConfig.enableMessageImageMask = enable;
}

- (void)setEventTextColor:(UIColor *)textColor {
    if (!textColor) {
        return;
    }
    chatViewConfig.eventTextColor = [textColor copy];
}

- (void)setNavigationBarTintColor:(UIColor *)tintColor {
    if (!tintColor) {
        return;
    }
    chatViewConfig.navBarTintColor = [tintColor copy];
}

- (void)setNavigationBarTitleColor:(UIColor *)tintColor {
    chatViewConfig.navTitleColor = tintColor;
}

- (void)setNavigationBarColor:(UIColor *)barColor {
    if (!barColor) {
        return;
    }
    chatViewConfig.navBarColor = [barColor copy];
}

- (void)setNavTitleColor:(UIColor *)titleColor {
    if (!titleColor) {
        return;
    }
    chatViewConfig.navTitleColor = titleColor;
}

- (void)setPullRefreshColor:(UIColor *)pullRefreshColor {
    if (!pullRefreshColor) {
        return;
    }
    chatViewConfig.pullRefreshColor = pullRefreshColor;
}

- (void)setChatWelcomeText:(NSString *)welcomText {

    if (!welcomText) {
        return;
    }
    NSString *str = [welcomText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str.length <= 0){
        return;
    }
    chatViewConfig.chatWelcomeText = [welcomText copy];
}

- (void)setAgentName:(NSString *)agentName {
    if (!agentName) {
        return;
    }
    chatViewConfig.agentName = [agentName copy];
}

- (void)enableIncomingAvatar:(BOOL)enable {
    chatViewConfig.enableIncomingAvatar = enable;
}

- (void)enableOutgoingAvatar:(BOOL)enable {
    chatViewConfig.enableOutgoingAvatar = enable;
}

- (void)setincomingDefaultAvatarImage:(UIImage *)image {
    if (!image) {
        return;
    }
    chatViewConfig.incomingDefaultAvatarImage = image;
}

- (void)setoutgoingDefaultAvatarImage:(UIImage *)image {
    if (!image) {
        return;
    }
    chatViewConfig.outgoingDefaultAvatarImage = image;
#ifdef INCLUDE_MIXDESK_SDK
    [MXServiceToViewInterface uploadClientAvatar:image completion:^(NSString *avatarUrl, NSError *error) {
    }];
#endif
}

- (void)setPhotoSenderImage:(UIImage *)image
           highlightedImage:(UIImage *)highlightedImage
{
    if (image) {
        chatViewConfig.photoSenderImage = image;
    }
    if (highlightedImage) {
        chatViewConfig.photoSenderHighlightedImage = highlightedImage;
    }
}

- (void)setVoiceSenderImage:(UIImage *)image
           highlightedImage:(UIImage *)highlightedImage
{
    if (image) {
        chatViewConfig.voiceSenderImage = image;
    }
    if (highlightedImage) {
        chatViewConfig.voiceSenderHighlightedImage = highlightedImage;
    }
}

- (void)setIncomingBubbleImage:(UIImage *)bubbleImage {
    if (!bubbleImage) {
        return;
    }
    chatViewConfig.incomingBubbleImage = bubbleImage;
}

- (void)setOutgoingBubbleImage:(UIImage *)bubbleImage {
    if (!bubbleImage) {
        return;
    }
    chatViewConfig.outgoingBubbleImage = bubbleImage;
}

- (void)setBubbleImageStretchInsets:(UIEdgeInsets)stretchInsets {
    chatViewConfig.bubbleImageStretchInsets = stretchInsets;
}

- (void)setNavRightButton:(UIButton *)rightButton {
    if (!rightButton) {
        return;
    }
    chatViewConfig.navBarRightButton = rightButton;
}

- (void)setNavLeftButton:(UIButton *)leftButton {
    if (!leftButton) {
        return;
    }
    chatViewConfig.navBarLeftButton = leftButton;
}

- (void)setNavTitleText:(NSString *)titleText {
    if (!titleText) {
        return;
    }
    chatViewConfig.navTitleText = titleText;
}

- (void)enableMessageSound:(BOOL)enable {
    chatViewConfig.enableMessageSound = enable;
}

- (void)enableTopPullRefresh:(BOOL)enable {
    chatViewConfig.enableTopPullRefresh = enable;
}

- (void)enableRoundAvatar:(BOOL)enable {
    chatViewConfig.enableRoundAvatar = enable;
}

- (void)enableTopAutoRefresh:(BOOL)enable {
    chatViewConfig.enableTopAutoRefresh = enable;
}

- (void)enableBottomPullRefresh:(BOOL)enable {
    chatViewConfig.enableBottomPullRefresh = enable;
}

- (void)enableChatWelcome:(BOOL)enable {
    chatViewConfig.enableChatWelcome = enable;
}

- (void)enableVoiceRecordBlurView:(BOOL)enable {
    chatViewConfig.enableVoiceRecordBlurView = enable;
}

- (void)enablePhotoLibraryEdit:(BOOL)enable {
    chatViewConfig.enablePhotoLibraryEdit = enable;
}

- (void)setIncomingMessageSoundFileName:(NSString *)soundFileName {
    if (!soundFileName) {
        return;
    }
    chatViewConfig.incomingMsgSoundFileName = soundFileName;
}

- (void)setOutgoingMessageSoundFileName:(NSString *)soundFileName {
    if (!soundFileName) {
        return;
    }
    chatViewConfig.outgoingMsgSoundFileName = soundFileName;
}

- (void)setMaxRecordDuration:(NSTimeInterval)recordDuration {
    chatViewConfig.maxVoiceDuration = recordDuration;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    chatViewConfig.statusBarStyle = statusBarStyle;
    chatViewConfig.didSetStatusBarStyle = true;
}

#ifdef INCLUDE_MIXDESK_SDK
- (void)enableSyncServerMessage:(BOOL)enable {
    chatViewConfig.enableSyncServerMessage = enable;
}

- (void)setLoginCustomizedId:(NSString *)customizedId {
    if (!customizedId) {
        return;
    }
    chatViewConfig.customizedId = customizedId;
}

- (void)setLoginMXClientId:(NSString *)MXClientId {
    if (!MXClientId) {
        return;
    }
    chatViewConfig.MXClientId = MXClientId;
}

- (void)enableEvaluationButton:(BOOL)enable {
    chatViewConfig.enableEvaluationButton = enable;
}

- (void)setClientInfo:(NSDictionary *)clientInfo override:(BOOL)override {
    if (!clientInfo) {
        return;
    }
    chatViewConfig.updateClientInfoUseOverride = override;
    chatViewConfig.clientInfo = clientInfo;
}

- (void)setClientInfo:(NSDictionary *)clientInfo {
    if (!clientInfo) {
        return;
    }
    chatViewConfig.clientInfo = clientInfo;
}

- (void)setLocalizedLanguage:(NSString *)language {
    if (!language) {
        return;
    }
    chatViewConfig.localizedLanguageStr = language;
}

- (void)didTapProductCard:(void (^)(NSString *))callBack {
    chatViewConfig.productCardCallBack = callBack;
}

#endif

- (MXChatViewController *)chatViewController {
    if (!_chatViewController) {
        _chatViewController = [[MXChatViewController alloc] initWithChatViewManager:chatViewConfig];
    }
    return _chatViewController;
}

@end
