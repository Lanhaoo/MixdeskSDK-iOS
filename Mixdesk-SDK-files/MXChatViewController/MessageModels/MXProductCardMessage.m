//
//  MXProductCardMessage.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/9/1.
//  Copyright © 2021 2020 Mixdesk. All rights reserved.
//

#import "MXProductCardMessage.h"

@implementation MXProductCardMessage

- (instancetype)initWithPictureUrl:(NSString *)pictureUrl title:(NSString *)title description:(NSString *)desc productUrl:(NSString *)productUrl andSalesCount:(long)count
{
    if (self = [super init]) {
        self.pictureUrl = pictureUrl;
        self.title  = title;
        self.desc = desc;
        self.productUrl  = productUrl;
        self.salesCount = count;
    }
    return self;
}

@end
