//
//  MXAdviseFormSubmitViewController.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MixdeskSDK/MixdeskSDK.h>
#import "MXChatViewConfig.h"

@interface MXPreChatSubmitViewController : UITableViewController

@property (nonatomic, copy) void(^completeBlock)(NSDictionary *userInfo);
@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, strong) MXPreChatData *formData;
@property (nonatomic, strong) MXPreChatMenuItem *selectedMenuItem;

@end
