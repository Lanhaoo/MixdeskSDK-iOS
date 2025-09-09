//
//  MXVideoCellModel.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXCellModelProtocol.h"
#import "MXVideoMessage.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const kMXCellPlayBtnHeight = 60.0;

typedef void (^VideoDownloadProgress)(float progress);

@interface MXVideoCellModel : NSObject <MXCellModelProtocol>

@property (nonatomic, copy) VideoDownloadProgress progressBlock;

/**
 * @brief 该cellModel的委托对象
 */
@property (nonatomic, weak) id<MXCellModelDelegate> delegate;

/**
 * bubble中的imageView的frame
 */
@property (nonatomic, readonly, assign) CGRect contentImageViewFrame;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readonly, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readonly, assign) CGRect avatarFrame;

/**
 * @brief 播放按钮的frame
 */
@property (nonatomic, readonly, assign) CGRect playBtnFrame;

/**
 * @brief 发送失败图标的frame
 */
@property (nonatomic, readonly, assign) CGRect sendFailureFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readonly, strong) UIImage *avatarImage;

/**
 * @brief 视频第一帧的图片
 */
@property (nonatomic, readonly, strong) UIImage *thumbnail;

/**
 * @brief 视频本地路径
 */
@property (nonatomic, readonly, copy) NSString *videoPath;

/**
 * @brief 视频服务器路径
 */
@property (nonatomic, readonly, copy) NSString *videoServerPath;

/**
 * @brief 消息的发送状态
 */
@property (nonatomic, readonly, assign) MXChatMessageSendStatus sendStatus;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readonly, assign) MXChatCellFromType cellFromType;

/**
 * @brief 是否正在下载视频
 */
@property (nonatomic, readonly, assign) BOOL isDownloading;

/**
 * @brief 消息的已读状态 (2: 已送达, 3: 已读)
 */
@property (nonatomic, assign) NSNumber *readStatus;

/**
 * @brief 已读状态指示器的frame
 */
@property (nonatomic, readonly, assign) CGRect readStatusIndicatorFrame;

- (MXVideoCellModel *)initCellModelWithMessage:(MXVideoMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MXCellModelDelegate>)delegate;

- (void)startDownloadMediaCompletion:(void (^)(NSString *mediaPath))completion;

@end

NS_ASSUME_NONNULL_END
