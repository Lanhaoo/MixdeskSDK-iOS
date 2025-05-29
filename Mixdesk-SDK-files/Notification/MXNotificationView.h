//
//  MXNotificationView.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2022/6/15.
//  Copyright © 2022 Mixdesk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat const kMXNotificationViewMargin = 20.0;
static CGFloat const kMXNotificationViewHeight = 80.0;
@interface MXNotificationView : UIView

-(void)configViewWithSenderName:(NSString *)name
                  senderAvatarUrl:(NSString *)avatar
                    sendContent:(NSString *)content;
        

@end
