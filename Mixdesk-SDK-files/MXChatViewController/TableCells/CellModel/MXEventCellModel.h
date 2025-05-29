//
//  MXEventCellModel.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXCellModelProtocol.h"
#import "MXEventMessage.h"

/**
 * MXEventCellModel定义了消息事件的基本类型数据，包括产生cell的内部所有view的显示数据，cell内部元素的frame等
 * @warning MXEventCellModel必须满足MXCellModelProtocol协议
 */
@interface MXEventCellModel : NSObject <MXCellModelProtocol>

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readonly, strong) NSString *messageId;

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 事件文字
 */
@property (nonatomic, readonly, copy) NSString *eventContent;

/**
 * @brief 事件消息的时间
 */
@property (nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 消息气泡button的frame
 */
@property (nonatomic, readonly, assign) CGRect eventLabelFrame;


/**
 *  根据MXMessage内容来生成cell model
 */
- (MXEventCellModel *)initCellModelWithMessage:(MXEventMessage *)message cellWidth:(CGFloat)cellWidth;

@end
