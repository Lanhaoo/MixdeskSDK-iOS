//
//  MXVideoMessage.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXVideoMessage.h"
#import "MXChatFileUtil.h"

@implementation MXVideoMessage

- (instancetype)initWithVideoServerPath:(NSString *)videoPath {
    if (self = [super init]) {
       
        if ([[videoPath substringToIndex:4] isEqualToString:@"http"]) {
            
            NSArray *arr = [videoPath componentsSeparatedByString:@"/"];
            if (arr.count > 3) {
                NSDateFormatter *formater = [NSDateFormatter new];
                formater.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                [formater setDateFormat:@"yyyyMMdd HH:mm:ss"];
                self.date = [formater dateFromString:[NSString stringWithFormat:@"%@ %@",arr[arr.count - 3], @"23:59:59"]];
            }
            
            NSString *mediaPath = [MXChatFileUtil getVideoCachePathWithServerUrl:videoPath];
            if ([MXChatFileUtil fileExistsAtPath:mediaPath isDirectory:NO]) {
                self.videoPath = mediaPath;
            } else {
                self.videoUrl = videoPath;
            }
        } else {
            // 视频没有发送成功，本地缓存的videoPath的名称如："345ewrrdf234.mov"
            self.videoPath = [MXChatFileUtil getVideoPathWithName:videoPath];
        }
    }
    return self;
}

- (void)handleAccessoryData:(NSDictionary *)accessoryData {
    
    if (accessoryData && ![accessoryData isEqual:[NSNull null]]) {
        if ([accessoryData objectForKey:@"thumb_url"] && ![[accessoryData objectForKey:@"thumb_url"] isEqual:[NSNull null]]) {
            self.thumbnailUrl = [accessoryData objectForKey:@"thumb_url"];
        }
    }
}

@end
