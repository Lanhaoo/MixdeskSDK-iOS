//
//  MXBaseMessage.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MXBaseMessage.h"

@implementation MXBaseMessage

- (instancetype)init {
    if (self = [super init]) {
        self.messageId = [[NSUUID UUID] UUIDString];
        self.conversionId = @"";
        self.fromType = MXChatMessageOutgoing;
        self.date = [NSDate date];
        self.userName = @"";
        self.userAvatarPath = @"";
        self.sendStatus = MXChatMessageSendStatusSending;
    }
    return self;
}

@end
