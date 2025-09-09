//
//  MXEventCellModel.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXEventCellModel.h"
#import "MXChatBaseCell.h"
#import "MXEventMessageCell.h" 
#import "MXStringSizeUtil.h"

static CGFloat const kMXEventCellTextToEdgeHorizontalSpacing = 32.0;
static CGFloat const kMXEventCellTextToEdgeVerticalSpacing = 16.0;
static CGFloat const kMXEventCellTextFontSize = 14.0;

@interface MXEventCellModel()
/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 事件消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 事件文字
 */
@property (nonatomic, readwrite, copy) NSString *eventContent;

/**
 * @brief 消息气泡button的frame
 */
@property (nonatomic, readwrite, assign) CGRect eventLabelFrame;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

@end

@implementation MXEventCellModel

- (MXEventCellModel *)initCellModelWithMessage:(MXEventMessage *)message cellWidth:(CGFloat)cellWidth {
    if (self = [super init]) {
        self.conversionId = message.conversionId;
        self.messageId = message.messageId;
        self.date = message.date;
        self.eventContent = message.content;
        self.cellWidth = cellWidth;
        CGFloat labelWidth = cellWidth - kMXEventCellTextToEdgeHorizontalSpacing * 2;
        CGFloat labelHeight = [MXStringSizeUtil getHeightForText:message.content withFont:[UIFont systemFontOfSize:kMXEventCellTextFontSize] andWidth:labelWidth];
        self.eventLabelFrame = CGRectMake(kMXEventCellTextToEdgeHorizontalSpacing, kMXEventCellTextToEdgeVerticalSpacing, labelWidth, labelHeight);
        self.cellHeight = self.eventLabelFrame.origin.y + self.eventLabelFrame.size.height + kMXEventCellTextToEdgeVerticalSpacing;
    }
    return self;
}

#pragma MXCellModelProtocol
- (CGFloat)getCellHeight {
    return self.cellHeight > 0 ? self.cellHeight : 0;
}

- (NSDate *)getCellDate {
    return self.date;
}

- (NSString *)getCellMessageId {
    return self.messageId;
}

- (NSString *)getMessageReadStatus {
  return @"";
}

- (NSString *)getMessageConversionId {
    return self.conversionId;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MXChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MXEventMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    self.eventLabelFrame = CGRectMake(cellWidth/2-self.eventLabelFrame.size.width/2, self.eventLabelFrame.origin.y, self.eventLabelFrame.size.width, self.eventLabelFrame.size.height);
}

@end
