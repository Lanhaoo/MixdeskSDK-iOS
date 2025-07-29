//
//  MXTextMessage.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MXTextMessage.h"
#import "NSString+MXRegular.h"

@implementation MXTextMessage

- (instancetype)initWithContent:(NSString *)content {
    if (self = [super init]) {
        self.content = content; //[content mx_textContent];
    }
    return self;
}

@end

@implementation MXMessageBottomTagModel

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        if ([dic objectForKey:@"name"] && ![[dic objectForKey:@"name"] isEqual:[NSNull null]]) {
            self.name = dic[@"name"];
        }
        if ([dic objectForKey:@"type"] && ![[dic objectForKey:@"type"] isEqual:[NSNull null]]) {
            NSString *type = dic[@"type"];
            if ([type isEqualToString:@"copy"]) {
                self.tagType = MXMessageBottomTagTypeCopy;
            } else if ([type isEqualToString:@"call"]) {
                self.tagType = MXMessageBottomTagTypeCall;
            } else if ([type isEqualToString:@"link"]) {
                self.tagType = MXMessageBottomTagTypeLink;
            }
        }
        if ([dic objectForKey:@"value"] && ![[dic objectForKey:@"value"] isEqual:[NSNull null]]) {
            self.value = dic[@"value"];
        }
    }
    return self;
}

@end
