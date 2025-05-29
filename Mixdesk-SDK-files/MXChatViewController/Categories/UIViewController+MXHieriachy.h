//
//  UIViewController+MXHieriachy.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/7/15.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController(MXHieriachy)

+ (UIViewController *)mx_topMostViewController;

@end
