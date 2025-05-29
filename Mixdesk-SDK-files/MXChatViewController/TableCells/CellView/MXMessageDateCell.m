//
//  MXMessageDateCell.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXMessageDateCell.h"
#import "MXMessageDateCellModel.h"
#import "MXDateFormatterUtil.h"

static CGFloat const kMXMessageDateLabelFontSize = 12.0;

@implementation MXMessageDateCell {
    UILabel *dateLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化时间label
        dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.font = [UIFont systemFontOfSize:kMXMessageDateLabelFontSize];
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
    }
    return self;
}


#pragma MXChatCellProtocol
- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
    if (![model isKindOfClass:[MXMessageDateCellModel class]]) {
        NSAssert(NO, @"传给MXMessageDateCell的Model类型不正确");
        return ;
    }
    MXMessageDateCellModel *cellModel = (MXMessageDateCellModel *)model;
    
    //刷新时间label
    dateLabel.text = [[MXDateFormatterUtil sharedFormatter] mixdeskStyleDateForDate:cellModel.date];
    dateLabel.frame = cellModel.dateLabelFrame;
}



@end
