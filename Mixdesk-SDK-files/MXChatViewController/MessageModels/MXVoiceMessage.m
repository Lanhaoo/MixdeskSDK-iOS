//
//  MXVoiceMessage.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MXVoiceMessage.h"
#import "MXServiceToViewInterface.h"

@implementation MXVoiceMessage

- (instancetype)init{
    if (self = [super init]) {
        self.voicePath = @"";
    }
    return self;
}

- (instancetype)initWithVoicePath:(NSString *)voicePath {
    self = [self init];
    self.voicePath = voicePath;
    return self;
}

- (instancetype)initWithVoiceData:(NSData *)voiceDate {
    self = [self init];
    self.voiceData = voiceDate;
    return self;
}

+ (void)setVoiceHasPlayedToDBWithMessageId:(NSString *)messageId {
    [MXServiceToViewInterface updateMessageWithId:messageId forAccessoryData:@{@"isPlayed":@(YES)}];
}

- (void)handleAccessoryData:(NSDictionary *)accessoryData {
    NSNumber *isPlayed = [accessoryData objectForKey:@"isPlayed"];
    if (isPlayed) {
        self.isPlayed = isPlayed.boolValue;
    }
}

@end
