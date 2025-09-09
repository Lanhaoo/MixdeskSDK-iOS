//
//  MXCellModelProtocol.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXChatBaseCell.h"
#import "MXChatFileUtil.h"
#import "MXBaseMessage.h"
#import "MXDateFormatterUtil.h"

//定义cell中的布局间距等
/**
 * 头像距离屏幕水平边沿距离
 */
static CGFloat const kMXCellAvatarToHorizontalEdgeSpacing = 16.0;
/**
 * 头像距离屏幕垂直边沿距离
 */
static CGFloat const kMXCellAvatarToVerticalEdgeSpacing = 16.0;
/**
 * 头像与聊天气泡之间的距离
 */
static CGFloat const kMXCellAvatarToBubbleSpacing = 8.0;
/**
 * 聊天气泡和其中的文字较大一边的水平间距
 */
static CGFloat const kMXCellBubbleToTextHorizontalLargerSpacing = 16.0;
/**
 * 聊天气泡和其中的文字较小一边的水平间距
 */
static CGFloat const kMXCellBubbleToTextHorizontalSmallerSpacing = 10.0;
/**
 * 聊天气泡和其中的文字垂直间距
 */
static CGFloat const kMXCellBubbleToTextVerticalSpacing = 12.0;
/**
 * 聊天气泡最大宽度与边沿的距离
 */
static CGFloat const kMXCellBubbleMaxWidthToEdgeSpacing = 48.0;
/**
 * 聊天头像的直径
 */
static CGFloat const kMXCellAvatarDiameter = 36.0;
/**
 * 聊天内容的文字大小
 */
static CGFloat const kMXCellTextFontSize = 16.0;
/**
 * 聊天内容间隔的时间cell高度
 */
static CGFloat const kMXChatMessageDateCellHeight = 36.0;
/**
 * 聊天内容间隔的时间的label向下偏移的数量
 */
static CGFloat const kMXChatMessageDateLabelVerticalOffset = 8.0;
/**
 * 聊天内容间隔的时间fontSize
 */
static CGFloat const kMXChatMessageDateLabelFontSize = 12.0;
/**
 * 聊天内容间隔的时间距离cell两端的间距
 */
static CGFloat const kMXChatMessageDateLabelToEdgeSpacing = 16.0;
/**
 * 聊天气泡和Indicator的间距
 */
static CGFloat const kMXCellBubbleToIndicatorSpacing = 8.0;
/**
 * indicator的diameter
 */
static CGFloat const kMXCellIndicatorDiameter = 33.0;
/**
 * 语音时长label的font size
 */
static CGFloat const kMXCellVoiceDurationLabelFontSize = 12.0;
/**
 * text label的line spacing
 */
static CGFloat const kMXTextCellLineSpacing = 6.0;


/**
 *  cell的来源枚举定义
 *  MXCellIncoming - 收到的消息cell
 *  MXCellOutgoing - 发送的消息cell
 */
typedef NS_ENUM(NSUInteger, MXChatCellFromType) {
    MXChatCellIncoming,
    MXChatCellOutgoing
};

/**
 * MXCellModelProtocol协议定义了ChatCell的view需要满足的方法，开发者也可根据自身需要，增加协议方法
 *
 */
@protocol MXCellModelProtocol <NSObject>

/**
 *  @return cell中的view.
 */
- (CGFloat)getCellHeight;

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer;

/**
 *  @return cell的消息时间.
 */
- (NSDate *)getCellDate;

/**
 *  该协议方法定义了，某一个cell是否是业务相关的cell，比如文字消息、图片消息、语音消息、链接消息即是业务相关cell等，而时间cell、提示cell等不属于业务相关cell
 *  该协议方法用于，判断两个业务相关cell时间相差过大，如果时间相差过大，他们之间需要插入一个时间cell
 *  @return 是否是业务相关的cell
 */
- (BOOL)isServiceRelatedCell;

/**
 *  @warning 非业务相关的cellModel，返回空字符串即可；
 *  @return cell的消息id.
 */
- (NSString *)getCellMessageId;

/**
 *  @return cell的消息已读状态.
 */
- (NSString *)getMessageReadStatus;

/**
 *  根据cellWidth来重新布局
 *
 *  @param cellWidth cell宽度
 */
- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth;

/**
  获取当前message所对应的conversionid
 */
- (NSString *)getMessageConversionId;

@optional
/**
 *  更新cell的sendType
 *
 *  @param sendType 发送类型
 */
- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus;

/**
 *  更新cell的readStatus
 *
 *  @param readStatus 已读状态
 */
- (void)updateCellReadStatus:(NSNumber *)readStatus;

/**
 *  更新cell的messageId
 *
 *  @param messageId 消息id
 */
- (void)updateCellMessageId:(NSString *)messageId;

/**
 *  更新cell的conversionId
 *
 *  @param conversionId 会话id
 */
- (void)updateCellConversionId:(NSString *)conversionId;

/**
 *  更新cell的messageDate
 *
 *  @param messageDate 消息时间
 */
- (void)updateCellMessageDate:(NSDate *)messageDate;

/**
 *  更新本机头像
 *
 *  @param avatarImage 头像 image
 */
- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage;

/**
 *  更新敏感词汇状态
 *
 *  @param state 是否是敏感词汇
 *  @param cellText 更新的文字（用于处理敏感词汇）
 */
- (void)updateSensitiveState:(BOOL)state cellText:(NSString *)cellText;

/**
 *  更多媒体本地缓存路径
 *
 *  @param serverPath 媒体的服务器地址
 */
- (void)updateMediaServerPath:(NSString *)serverPath;

/**
 *  更新cell的readStatus
 *
 *  @param readStatus 消息状态
 */
- (void)updateCellReadStatus:(NSNumber *)readStatus;

@end

/**
 * MXCellModelDataLoadDelegate协议定义了cellModel中的委托方法，需要在ViewModel进行实现；
 */
@protocol MXCellModelDelegate <NSObject>

/**
 * 该委托定义了cell中有数据更新，通知tableView可以进行cell的刷新了；
 * @param messageId 该cell中的消息id
 */
- (void)didUpdateCellDataWithMessageId:(NSString *)messageId;

- (void)didTapHighMenuWithText:(NSString *)menuText;

@end
