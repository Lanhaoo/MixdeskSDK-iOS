//
//  AppDelegate.m
//  MXEcoboostSDK-test
//
//  Created by ijinmao on 15/11/11.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "AppDelegate.h"
#import <MixdeskSDK/MXManager.h>
#import "MXServiceToViewInterface.h"
#import "ViewController.h"
#import "MXNotificationManager.h"
#import <CoreTelephony/CTCellularData.h>


#define APPKeyInTest @"a71c257c80dfe883d92a64dca323ec20"
#define APPKeyClientTest @"7cd6134129e19707bfe43a84c1fca6e7"

@interface AppDelegate ()

@property (nonatomic, assign) BOOL mxRegisterState;
@property (nonatomic, strong) CTCellularData *cellularData;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //推送注册
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                | UIUserNotificationTypeBadge
                                                | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
#else
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
#endif
    
#pragma mark  集成第一步: 初始化,  参数:appkey
    [self initMixdeskSDK];
//    [self networkPermissionMonitoring];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    
    return YES;
}

#pragma mark  集成第一步: 初始化,  参数:appkey
- (void)initMixdeskSDK {
    // mixdesk 1 712339b0ab98565a51cf93b66628e081
    __weak typeof(self) weakSelf = self;
    [MXManager initWithAppkey:@"20ae5a63dca0e1a10d858cb47aa74e96" completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            weakSelf.mxRegisterState = YES;
            [[MXNotificationManager sharedManager] openMXGroupNotificationServer];
            NSLog(@"Mixdesk SDK：初始化成功,%@", error);
        } else {
            weakSelf.mxRegisterState = NO;
            NSLog(@"Mixdesk SDK：初始化失败:%@",error);
        }
    }];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    #pragma mark  集成第二步: 进入前台 打开mixdesk服务
    [MXManager openMixdeskService];
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    #pragma mark  集成第三步: 进入后台 关闭Mixdesk服务
    [MXManager closeMixdeskService];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    #pragma mark  集成第四步: 上传设备deviceToken
    NSLog(@"device Token ====%@", deviceToken);
    [MXManager registerDeviceToken:deviceToken];
    
    /*  swift 项目这样处理
     let devicetokenStr = (NSData.init(data: deviceToken).description as NSString).trimmingCharacters(in: NSCharacterSet(charactersIn: "<>") as CharacterSet).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
     MXManager.registerDeviceTokenString(devicetokenStr)
     */
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

// 处理第一次安装app，还没授权网络权限，sdk初始化失败问题
- (void)networkPermissionMonitoring {
    self.cellularData = [[CTCellularData alloc] init];
    __weak typeof(self) weakSelf = self;
    self.cellularData.cellularDataRestrictionDidUpdateNotifier=^(CTCellularDataRestrictedState state) {
        switch(state){
            case kCTCellularDataRestricted:
            case kCTCellularDataNotRestricted:
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf && !strongSelf.mxRegisterState) {
                        strongSelf.mxRegisterState = YES;
                        [strongSelf initMixdeskSDK];
                    }
                });
            }
                break;
            default:
                break;
        }
    };
}
@end
