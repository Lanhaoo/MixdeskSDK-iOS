//
//  UIViewController+MXHieriachy.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/7/15.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "UIViewController+MXHieriachy.h"

@implementation UIViewController(MXHieriachy)

+ (UIViewController *)mx_topMostViewController
{
    UIViewController *topController = [self topWindow].rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

+ (UIWindow *)topWindow
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            window.windowLevel == UIWindowLevelNormal &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    
    return [UIApplication sharedApplication].keyWindow;
}


@end
