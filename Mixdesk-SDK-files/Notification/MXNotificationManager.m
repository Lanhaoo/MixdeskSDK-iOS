//
//  MXNotificationManager.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/5/30.
//  Copyright © 2022 Mixdesk Inc. All rights reserved.
//

#import "MXNotificationManager.h"
#import "MXToolUtil.h"
#import "MXNotificationView.h"
#import "MXServiceToViewInterface.h"
#import "MXChatViewManager.h"
#import "MXChatViewController.h"

#define kMXNotificationWindowContentHeight [MXToolUtil kMXObtainStatusBarHeight] + 100
static NSInteger const kMXNotificationDismissTime = 5.0;

@interface MXNotificationManager ()<MXGroupNotificationDelegate>

@property (strong, nonatomic) UIWindow *notificationWindow;

@property (strong, nonatomic) MXNotificationView *notificationView;

@property (nonatomic, strong) dispatch_source_t countdownTimer;

@property (nonatomic, assign) BOOL currentLongGesture;

@property (nonatomic, strong) MXGroupNotification *currentNotification;

@end

@implementation MXNotificationManager

+ (MXNotificationManager *)sharedManager {
    static dispatch_once_t once;
    static MXNotificationManager * instance = nil;
    dispatch_once(&once, ^{
        instance = [super new];
    });
    return instance;
}

- (void)openMXGroupNotificationServer {
    [MXServiceToViewInterface openMXGroupNotificationServiceWithDelegate:self];
}

- (void)showNotification {
    if (!self.notificationWindow) {
        [self createNotificationWindow];
        [self.notificationWindow addSubview:self.notificationView];
        
        UISwipeGestureRecognizer *topSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [topSwipe setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self.notificationWindow addGestureRecognizer:topSwipe];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self.notificationWindow addGestureRecognizer:longGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self.notificationWindow addGestureRecognizer:tap];
        
        [self.notificationWindow makeKeyAndVisible];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.notificationWindow.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kMXNotificationWindowContentHeight);
        } completion:^(BOOL finished) {
            [self resetCountdown:kMXNotificationDismissTime];
        }];
    } else {
        if (!self.currentLongGesture) {
            [self resetCountdown:kMXNotificationDismissTime];
        }
    }
}

- (void)dismissNotification {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.notificationWindow.frame = CGRectMake(0, -(kMXNotificationWindowContentHeight), [UIScreen mainScreen].bounds.size.width, kMXNotificationWindowContentHeight);
    } completion:^(BOOL finished) {
        self.notificationWindow = nil;
    }];
}

- (void)createNotificationWindow {
    CGRect bounds = CGRectMake(0, -(kMXNotificationWindowContentHeight), [UIScreen mainScreen].bounds.size.width, kMXNotificationWindowContentHeight);
    self.notificationWindow = [[UIWindow alloc] initWithFrame:bounds];
    self.notificationWindow.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    self.notificationWindow.windowLevel = 4000;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.currentLongGesture = YES;
        [self cancelCountdownTimer];
    } else {
        self.currentLongGesture = NO;
        [self resetCountdown:kMXNotificationDismissTime];
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self cancelCountdownTimer];
    [self dismissNotification];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    [[NSNotificationCenter defaultCenter] postNotificationName:MX_CLICK_GROUP_NOTIFICATION object:nil userInfo:[self.currentNotification fromMapping]];
    [self cancelCountdownTimer];
    [self dismissNotification];
    if (!self.handleNotification) {
        [MXServiceToViewInterface insertMXGroupNotificationToConversion:self.currentNotification];
        self.currentNotification = nil;
        UIViewController *vc = [self findCurrentShowingViewController];
        if (![vc isKindOfClass:[MXChatViewController class]]) {
            MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
            [chatViewManager pushMXChatViewControllerInViewController:vc];
        }
    }
}

- (MXNotificationView *)notificationView {
    if (!_notificationView) {
        _notificationView = [[MXNotificationView alloc] initWithFrame:CGRectMake(kMXNotificationViewMargin, [MXToolUtil kMXObtainStatusBarHeight], [MXToolUtil kMXScreenWidth] - kMXNotificationViewMargin * 2, kMXNotificationViewHeight)];
    }
    return _notificationView;
}

- (void)countDownWithTimer:(dispatch_source_t)timer timeInterval:(NSTimeInterval)timeInterval complete:(void(^)(void))completeBlock {
    __block int timeout = timeInterval;
    if (timeout != 0) {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), (int64_t)(1.0 * NSEC_PER_SEC), 0);
        dispatch_source_set_event_handler(timer, ^{
            if(timeout <= 0){ //倒计时结束，关闭
                dispatch_source_cancel(timer);
                dispatch_async(dispatch_get_main_queue(), ^{ // block 回调
                    if (completeBlock) {
                        completeBlock();
                    }
                });
            }else{
                timeout--;
            }
        });
        dispatch_resume(timer);
    }
}

- (void)resetCountdown:(NSInteger)time {
    [self cancelCountdownTimer];
    NSInteger count = time;
    // 创建一个队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.countdownTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    __weak typeof(self) weakSelf = self;
    [self countDownWithTimer:self.countdownTimer timeInterval:count complete:^{
        [weakSelf dismissNotification];
    }];
}

- (void)cancelCountdownTimer {
    if (_countdownTimer) {
        dispatch_source_cancel(_countdownTimer);
        _countdownTimer = nil;
    }
}

- (UIViewController *)findCurrentShowingViewController {
    
    UIWindow* window = nil;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
        window = [UIApplication sharedApplication].keyWindow;
    }
    UIViewController *vc = window.rootViewController;

    return [self findCurrentShowingViewControllerFrom:vc];
}

- (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    // 递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) {
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }

    return currentShowingVC;
}

#pragma mark MXGroupNotificationDelegate

-(void)didReceiveMXGroupNotification:(NSArray<MXGroupNotification *> *)message {
    if (message.count > 0) {
        MXGroupNotification *notification = [message lastObject];
        self.currentNotification = notification;
        [self.notificationView configViewWithSenderName:notification.name senderAvatarUrl:notification.avatar sendContent:notification.content];
        [self showNotification];
    }
}

@end
