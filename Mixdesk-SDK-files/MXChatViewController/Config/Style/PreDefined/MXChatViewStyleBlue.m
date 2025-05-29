//
//  MXChatViewStyleBlue.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/3/30.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXChatViewStyleBlue.h"

@implementation MXChatViewStyleBlue

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor mx_colorWithHexString:belizeHole];
        self.navTitleColor = [UIColor mx_colorWithHexString:gallery];
        self.navBarTintColor = [UIColor mx_colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor mx_colorWithHexString:dodgerBlue];
        self.incomingMsgTextColor = [UIColor mx_colorWithHexString:gallery];
        
        self.outgoingBubbleColor = [UIColor mx_colorWithHexString:gallery];
        self.outgoingMsgTextColor = [UIColor mx_colorWithHexString:dodgerBlue];
        
        self.pullRefreshColor = [UIColor mx_colorWithHexString:belizeHole];
        
        self.backgroundColor = [UIColor whiteColor];
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

@end
