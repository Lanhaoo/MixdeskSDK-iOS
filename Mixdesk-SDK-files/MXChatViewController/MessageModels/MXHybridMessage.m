//
//  MXHybridMessage.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXHybridMessage.h"

@implementation MXHybridMessage

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.summary = dictionary[@"summary"] ?: @"";
        self.thumbnail = dictionary[@"thumbnail"] ?: @"";
        self.content = dictionary[@"content"] ?: @"";
    }
    return self;
}

- (void)parseFeedbackButtonsFromDictionary:(NSDictionary *)dictionary {
    NSArray *buttonsArray = dictionary[@"option"];
    if (buttonsArray && [buttonsArray isKindOfClass:[NSArray class]]) {
        NSMutableArray *feedbackButtons = [NSMutableArray array];
        
        for (NSDictionary *buttonDict in buttonsArray) {
            if ([buttonDict isKindOfClass:[NSDictionary class]]) {
                MXFeedbackButtonModel *buttonModel = [[MXFeedbackButtonModel alloc] initWithDictionary:buttonDict];
                [feedbackButtons addObject:buttonModel];
            }
        }
        
        if (feedbackButtons.count > 0) {
            self.feedbackBtns = [feedbackButtons copy];
        }
    }
}

@end

@implementation MXFeedbackButtonModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    // 使用与接口定义一致的属性名
    self.content = dictionary[@"content"] ?: @"";
  }
  return self;
}

@end