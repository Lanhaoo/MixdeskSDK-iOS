//
//  MXMXWebViewBubbleCellModel.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXCellModelProtocol.h"
#import "MXTagListView.h"
#import "MXEmbededWebView.h"
#import "MXQuickBtnView.h"
#import "MXFeedbackBtnView.h"

@class MXRichTextMessage;
@interface MXWebViewBubbleCellModel : NSObject <MXCellModelProtocol>

/**
 * @brief cell的高度
 */
@property (nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 标签的tagList
 */
@property (nonatomic, readonly, strong) MXTagListView *cacheTagListView;

/**
 * @brief 快捷按钮视图
 */
@property (nonatomic, readonly, strong) MXQuickBtnView *cacheQuickBtnView;

/**
 * @brief 反馈按钮视图
 */
@property (nonatomic, readonly, strong) MXFeedbackBtnView *cacheFeedbackBtnView;

/**
 * @brief 标签的数据源
 */
@property (nonatomic, readonly, strong) NSArray *cacheTags;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleFrame;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readonly, copy) UIImage *bubbleImage;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, copy) UIImage *avatarImage;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;


@property (nonatomic, readonly, strong) MXEmbededWebView *contentWebView;

- (id)initCellModelWithMessage:(MXRichTextMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MXCellModelDelegate>)delegator;

@end
