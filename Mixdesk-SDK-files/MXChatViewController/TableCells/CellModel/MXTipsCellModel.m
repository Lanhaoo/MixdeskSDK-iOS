//
//  MXTipsCellModel.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXTipsCellModel.h"
#import "MXBundleUtil.h"
#import "MXChatBaseCell.h"
#import "MXChatViewConfig.h"
#import "MXStringSizeUtil.h"
#import "MXTipsCell.h"

// 上下两条线与cell垂直边沿的间距
static CGFloat const kMXMessageTipsLabelLineVerticalMargin = 2.0;
static CGFloat const kMXMessageTipsCellVerticalSpacing = 24.0;
static CGFloat const kMXMessageTipsCellHorizontalSpacing = 24.0;
static CGFloat const kMXMessageReplyTipsCellVerticalSpacing = 8.0;
static CGFloat const kMXMessageReplyTipsCellHorizontalSpacing = 8.0;
static CGFloat const kMXMessageTipsLineHeight = 0.5;
static CGFloat const kMXMessageTipsBottomBtnHeight = 40.0;
static CGFloat const kMXMessageTipsBottomBtnHorizontalSpacing = 25.0;
CGFloat const kMXMessageTipsFontSize = 13.0;

@interface MXTipsCellModel ()
/**
 * @brief cell的宽度
 */
@property(nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property(nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 提示文字
 */
@property(nonatomic, readwrite, copy) NSString *tipText;

/**
 * @brief 提示文字的额外属性
 */
@property(nonatomic, readwrite, strong)
    NSArray<NSDictionary<NSString *, id> *> *tipExtraAttributes;

/**
 * @brief 提示文字的额外属性的 range 的数组
 */
@property(nonatomic, readwrite, strong)
    NSArray<NSValue *> *tipExtraAttributesRanges;

/**
 * @brief 提示label的frame
 */
@property(nonatomic, readwrite, assign) CGRect tipLabelFrame;

/**
 * @brief 上线条的frame
 */
@property(nonatomic, readwrite, assign) CGRect topLineFrame;

/**
 *  是否显示上下两个线条
 */
@property(nonatomic, readwrite, assign) BOOL enableLinesDisplay;

/**
 * 下线条的frame
 */
@property(nonatomic, readwrite, assign) CGRect bottomLineFrame;

/**
 * 底部的btn的frame
 */
@property(nonatomic, readwrite, assign) CGRect bottomBtnFrame;

/**
 *  底部bottom提示文字
 */
@property(nonatomic, readwrite, copy) NSString *bottomBtnTitle;

/**
 * @brief 提示的时间
 */
@property(nonatomic, readwrite, copy) NSDate *date;

// tip 的类型
@property(nonatomic, readwrite, assign) MXTipType tipType;

@end

@implementation MXTipsCellModel

#pragma initialize
/**
 *  根据tips内容来生成cell model
 */
- (MXTipsCellModel *)initCellModelWithTips:(NSString *)tips
                                 cellWidth:(CGFloat)cellWidth
                        enableLinesDisplay:(BOOL)enableLinesDisplay {
  if (self = [super init]) {
    self.tipType = MXTipTypeRedirect;
    self.date = [NSDate date];
    self.tipText = tips;
    self.enableLinesDisplay = enableLinesDisplay;

    // tip frame
    CGFloat tipCellHoriSpacing = enableLinesDisplay
                                     ? kMXMessageTipsCellHorizontalSpacing
                                     : kMXMessageReplyTipsCellHorizontalSpacing;
    CGFloat tipCellVerSpacing = enableLinesDisplay
                                    ? kMXMessageTipsCellVerticalSpacing
                                    : kMXMessageReplyTipsCellVerticalSpacing;
    CGFloat tipsWidth = cellWidth - tipCellHoriSpacing * 2;
    CGFloat tipsHeight = [MXStringSizeUtil
        getHeightForText:tips
                withFont:[UIFont systemFontOfSize:kMXMessageTipsFontSize]
                andWidth:tipsWidth];
    CGRect tipLabelFrame = CGRectMake(tipCellHoriSpacing, tipCellVerSpacing,
                                      tipsWidth, tipsHeight);
    self.tipLabelFrame = tipLabelFrame;

    self.cellHeight = tipCellVerSpacing * 2 + tipsHeight;

    // 上线条的frame
    CGFloat lineWidth = cellWidth;
    self.topLineFrame = CGRectMake(cellWidth / 2 - lineWidth / 2,
                                   kMXMessageTipsLabelLineVerticalMargin,
                                   lineWidth, kMXMessageTipsLineHeight);

    // 下线条的frame
    self.bottomLineFrame =
        CGRectMake(self.topLineFrame.origin.x,
                   self.cellHeight - kMXMessageTipsLabelLineVerticalMargin -
                       kMXMessageTipsLineHeight,
                   lineWidth, kMXMessageTipsLineHeight);

    // tip的文字额外属性
    if (tips.length > 4) {
      if ([[tips substringToIndex:3] isEqualToString:@"接下来"]) {
        NSRange firstRange = [tips rangeOfString:@" "];
        NSString *subTips = [tips substringFromIndex:firstRange.location + 1];
        NSRange lastRange = [subTips rangeOfString:@"为你服务"];
        NSRange agentNameRange =
            NSMakeRange(firstRange.location + 1, lastRange.location - 1);
        self.tipExtraAttributesRanges =
            @[ [NSValue valueWithRange:agentNameRange] ];
        self.tipExtraAttributes = @[ @{
          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold"
                                                size:13],
          NSForegroundColorAttributeName : [MXChatViewConfig sharedConfig]
              .chatViewStyle.btnTextColor
        } ];
      }
    }
  }
  return self;
}

/**
 *  生成留言提示的 cell，支持点击留言
 */
- (MXTipsCellModel *)initBotTipCellModelWithTips:(NSString *)tips
                                       cellWidth:(CGFloat)cellWidth
                                         tipType:(MXTipType)tipType {
  if (self = [super init]) {
    self.tipType = tipType;
    self.date = [NSDate date];
    if (tips.length > 0) {
      self.tipText = tips;
    }
    self.enableLinesDisplay = false;

    // tip frame
    CGFloat tipsWidth =
        cellWidth - kMXMessageReplyTipsCellHorizontalSpacing * 2;
    CGFloat tipsHeight = [MXStringSizeUtil
        getHeightForText:self.tipText
                withFont:[UIFont systemFontOfSize:kMXMessageTipsFontSize]
                andWidth:tipsWidth];
    CGRect tipLabelFrame = CGRectMake(kMXMessageReplyTipsCellHorizontalSpacing,
                                      kMXMessageReplyTipsCellVerticalSpacing,
                                      tipsWidth, tipsHeight);
    self.tipLabelFrame = tipLabelFrame;

    self.cellHeight = kMXMessageReplyTipsCellVerticalSpacing * 2 + tipsHeight;

    // 上线条的frame
    CGFloat lineWidth = cellWidth;
    self.topLineFrame = CGRectMake(cellWidth / 2 - lineWidth / 2,
                                   kMXMessageTipsLabelLineVerticalMargin,
                                   lineWidth, kMXMessageTipsLineHeight);

    // 下线条的frame
    self.bottomLineFrame =
        CGRectMake(self.topLineFrame.origin.x,
                   self.cellHeight - kMXMessageTipsLabelLineVerticalMargin -
                       kMXMessageTipsLineHeight,
                   lineWidth, kMXMessageTipsLineHeight);

    // tip的文字额外属性
    NSString *tapText = [NSString string];
    if ([self.tipText containsString:@"转人工"]) {
      tapText = @"转人工";
    } else {
      tapText = [self.tipText containsString:@"轉人工"]
                    ? @"轉人工"
                    : @"Tap here to redirect to an agent";
    }

    NSRange replyTextRange = [self.tipText rangeOfString:tapText];
    self.tipExtraAttributesRanges =
        @[ [NSValue valueWithRange:replyTextRange] ];
    self.tipExtraAttributes = @[ @{
      NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:13],
      NSForegroundColorAttributeName : [MXChatViewConfig sharedConfig]
          .chatViewStyle.btnTextColor
    } ];
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
  return [[MXTipsCell alloc] initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:cellReuseIdentifer];
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
  CGFloat tipCellHoriSpacing = self.tipType == MXTipTypeRedirect
                                   ? kMXMessageTipsCellHorizontalSpacing
                                   : kMXMessageReplyTipsCellHorizontalSpacing;
  CGFloat tipCellVerSpacing = self.tipType == MXTipTypeRedirect
                                  ? kMXMessageTipsCellVerticalSpacing
                                  : kMXMessageReplyTipsCellVerticalSpacing;

  // tip frame
  CGFloat tipsWidth = cellWidth - tipCellHoriSpacing * 2;
  self.tipLabelFrame = CGRectMake(tipCellHoriSpacing, tipCellVerSpacing,
                                  tipsWidth, self.tipLabelFrame.size.height);

  // 上线条的frame
  CGFloat lineWidth = cellWidth;
  self.topLineFrame = CGRectMake(cellWidth / 2 - lineWidth / 2,
                                 kMXMessageTipsLabelLineVerticalMargin,
                                 lineWidth, kMXMessageTipsLineHeight);

  // 下线条的frame
  self.bottomLineFrame =
      CGRectMake(self.topLineFrame.origin.x,
                 self.cellHeight - kMXMessageTipsLabelLineVerticalMargin -
                     kMXMessageTipsLineHeight,
                 lineWidth, kMXMessageTipsLineHeight);

  // cell height
  self.cellHeight =
      self.bottomLineFrame.origin.y + self.bottomLineFrame.size.height + 0.5;
}

@end
