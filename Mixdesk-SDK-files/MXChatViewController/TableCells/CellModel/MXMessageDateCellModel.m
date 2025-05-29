//
//  MXMessageDateCellModel.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXMessageDateCellModel.h"
#import "MXChatBaseCell.h"
#import "MXMessageDateCell.h"
#import "MXDateFormatterUtil.h"
#import "MXStringSizeUtil.h"


@interface MXMessageDateCellModel()
/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 消息的中文时间
 */
@property (nonatomic, readwrite, copy) NSString *dateString;

/**
 * @brief 消息气泡button的frame
 */
@property (nonatomic, readwrite, assign) CGRect dateLabelFrame;

@end

@implementation MXMessageDateCellModel

#pragma initialize
/**
 *  根据时间来生成cell model
 */
- (MXMessageDateCellModel *)initCellModelWithDate:(NSDate *)date cellWidth:(CGFloat)cellWidth{
    if (self = [super init]) {
        self.date = date;
        self.dateString = [[MXDateFormatterUtil sharedFormatter] mixdeskStyleDateForDate:date];
        //时间文字size
        CGFloat dateLabelWidth = cellWidth - kMXChatMessageDateLabelToEdgeSpacing * 2;
        CGFloat dateLabelHeight = [MXStringSizeUtil getHeightForText:self.dateString withFont:[UIFont systemFontOfSize:kMXChatMessageDateLabelFontSize] andWidth:dateLabelWidth];
        self.dateLabelFrame = CGRectMake(cellWidth/2-dateLabelWidth/2, kMXChatMessageDateCellHeight/2-dateLabelHeight/2+kMXChatMessageDateLabelVerticalOffset, dateLabelWidth, dateLabelHeight);
        
        self.cellHeight = kMXChatMessageDateCellHeight;
    }
    return self;
}

#pragma MXCellModelProtocol
- (CGFloat)getCellHeight {
    return self.cellHeight > 0 ? self.cellHeight : 0;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MXChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MXMessageDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return false;
}

- (NSString *)getCellMessageId {
    return @"";
}

- (NSString *)getMessageConversionId {
    return @"";
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    self.dateLabelFrame = CGRectMake(cellWidth/2-self.dateLabelFrame.size.width/2, kMXChatMessageDateCellHeight/2-self.dateLabelFrame.size.height/2+kMXChatMessageDateLabelVerticalOffset, self.dateLabelFrame.size.width, self.dateLabelFrame.size.height);
}


@end
