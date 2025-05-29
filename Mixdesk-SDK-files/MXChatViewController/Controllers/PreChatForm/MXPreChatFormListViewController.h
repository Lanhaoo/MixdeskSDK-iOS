//
//  MXPreAdviseFormListViewController.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 列表Header到屏幕左右两边的间距
 */
static CGFloat const kMXPreChatHeaderHorizontalSpacing = 10.0;

/**
 * 列表Header中的标题文字距bottom的距离
 */
static CGFloat const kMXPreChatHeaderBottom = 10.0;

@class MXChatViewConfig;
@interface MXPreChatFormListViewController : UITableViewController

+ (MXPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(NSDictionary *userInfo))block cancle:(void(^)(void))cancelBlock;


@end
