//
//  MXEventMessageCell.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXEventMessageCell.h"
#import "MXEventCellModel.h"
#import "MXChatViewConfig.h"

static CGFloat const kMXMessageEventLabelFontSize = 14.0;

@implementation MXEventMessageCell {
    UILabel *eventLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化事件label
        eventLabel = [[UILabel alloc] init];
        eventLabel.textColor = [MXChatViewConfig sharedConfig].eventTextColor;
        eventLabel.textAlignment = NSTextAlignmentCenter;
        eventLabel.font = [UIFont systemFontOfSize:kMXMessageEventLabelFontSize];
        [self.contentView addSubview:eventLabel];
    }
    return self;
}

#pragma MXChatCellProtocol
- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
    if (![model isKindOfClass:[MXEventCellModel class]]) {
        NSAssert(NO, @"传给MXEventMessageCell的Model类型不正确");
        return ;
    }
    MXEventCellModel *cellModel = (MXEventCellModel *)model;
    
    //刷新时间label
    eventLabel.text = cellModel.eventContent;
    eventLabel.frame = cellModel.eventLabelFrame;
}

@end
