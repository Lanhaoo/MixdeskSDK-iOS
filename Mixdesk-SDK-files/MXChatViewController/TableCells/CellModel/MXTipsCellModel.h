//
//  MXTipsCellModel.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXCellModelProtocol.h"

extern CGFloat const kMXMessageTipsFontSize;

//tip 类型
typedef NS_ENUM(NSUInteger, MXTipType) {
    MXTipTypeRedirect,
    MXTipTypeBotRedirect,
    MXTipTypeBotManualRedirect
};

/**
 * MXTipsCellModel定义了消息提示的基本类型数据，包括产生cell的内部所有view的显示数据，cell内部元素的frame等
 * @warning MXTipsCellModel必须满足MXCellModelProtocol协议
 */
@interface MXTipsCellModel : NSObject <MXCellModelProtocol>

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 提示文字
 */
@property (nonatomic, readonly, copy) NSString *tipText;

/**
 * @brief 提示文字的额外属性
 */
@property (nonatomic, readonly, strong) NSArray<NSDictionary<NSString *, id> *> *tipExtraAttributes;

/**
 * @brief 提示文字的额外属性的 range 的数组
 */
@property (nonatomic, readonly, strong) NSArray<NSValue *> *tipExtraAttributesRanges;

/**
 * @brief 提示的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 提示label的frame
 */
@property (nonatomic, readonly, assign) CGRect tipLabelFrame;

/**
 * @brief 上线条的frame
 */
@property (nonatomic, readonly, assign) CGRect topLineFrame;

/**
 * @brief 下线条的frame
 */
@property (nonatomic, readonly, assign) CGRect bottomLineFrame;

/**
 *  是否显示上下两个线条
 */
@property (nonatomic, readonly, assign) BOOL enableLinesDisplay;

@property (nonatomic, readonly, assign) CGRect bottomBtnFrame;

@property (nonatomic, readonly, copy) NSString *bottomBtnTitle;

/**
 *  tip 类型
 */
@property (nonatomic, readonly, assign) MXTipType tipType;

/**
 *  根据tips内容来生成cell model
 */
- (MXTipsCellModel *)initCellModelWithTips:(NSString *)tips
                                 cellWidth:(CGFloat)cellWidth
                        enableLinesDisplay:(BOOL)enableLinesDisplay;

/**
 *  生成留言提示的 cell，支持点击留言
 */
- (MXTipsCellModel *)initBotTipCellModelWithTips:(NSString *)tips
                                       cellWidth:(CGFloat)cellWidth
                                              tipType:(MXTipType)tipType;
@end
