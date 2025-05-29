//
//  MXChatViewStyleDark.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/3/30.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXChatViewStyleDark.h"

@implementation MXChatViewStyleDark

- (instancetype)init {
    if (self = [super init]) {
        self.navBarColor =  [UIColor mx_colorWithHexString:midnightBlue];
        self.navTitleColor = [UIColor mx_colorWithHexString:gallery];
        self.navBarTintColor = [UIColor mx_colorWithHexString:clouds];
        
        self.incomingBubbleColor = [UIColor mx_colorWithHexString:clouds];
        self.incomingMsgTextColor = [UIColor mx_colorWithHexString:wetAsphalt];
        
        self.outgoingBubbleColor = [UIColor mx_colorWithHexString:silver];
        self.outgoingMsgTextColor = [UIColor mx_colorWithHexString:wetAsphalt];
        
        self.pullRefreshColor = [UIColor mx_colorWithHexString:midnightBlue];
        
        self.backgroundColor = [UIColor mx_colorWithHexString:midnightBlue];
        
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

@end
