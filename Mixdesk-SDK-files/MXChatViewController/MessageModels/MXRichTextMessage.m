//
//  MXRichTextMessage.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXRichTextMessage.h"

@implementation MXRichTextMessage

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.summary = dictionary[@"summary"] ?: @"";
        self.thumbnail = dictionary[@"thumbnail"] ?: @"";
        self.content = dictionary[@"content"] ?: @"";
    }
    return self;
}

@end

@implementation MXMessageBottomQuickBtnModel

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.btn_text = [dic objectForKey:@"btn_text"];
        self.btn_type = [[dic objectForKey:@"btn_type"] integerValue];
        self.content = [dic objectForKey:@"content"];
        self.id = [[dic objectForKey:@"id"] integerValue];
        self.style = [dic objectForKey:@"style"];
        self.func = [[dic objectForKey:@"func"] integerValue];
        self.func_id = [dic objectForKey:@"func_id"];
    }
    return self;
}

@end
