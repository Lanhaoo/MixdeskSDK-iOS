//
//  MXVideoCellModel.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXVideoCellModel.h"
#import "MXVideoMessageCell.h"
#import "MXServiceToViewInterface.h"
#import "MXImageUtil.h"
#import "MXChatFileUtil.h"
#import "MXToast.h"
#import "MXBundleUtil.h"
#ifndef INCLUDE_MIXDESK_SDK
#import "UIImageView+WebCache.h"
#endif
/**
 * 聊天气泡和其中的图片垂直间距
 */
static CGFloat const kMXCellBubbleToImageSpacing = 12.0;

@interface MXVideoCellModel ()

/**
 * @brief cell的宽度
 */
@property (nonatomic, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, assign) CGFloat cellHeight;

/**
 * bubble中的imageView的frame
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 播放按钮的frame
 */
@property (nonatomic, readwrite, assign) CGRect playBtnFrame;

/**
 * @brief 发送失败图标的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, strong) UIImage *avatarImage;

/**
 * @brief 视频第一帧的图片
 */
@property (nonatomic, readwrite, strong) UIImage *thumbnail;

/**
 * @brief 视频本地路径
 */
@property (nonatomic, readwrite, copy) NSString *videoPath;

/**
 * @brief 视频服务器路径
 */
@property (nonatomic, readwrite, copy) NSString *videoServerPath;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MXChatCellFromType cellFromType;

/**
 * @brief 消息的发送状态
 */
@property (nonatomic, readwrite, assign) MXChatMessageSendStatus sendStatus;

/**
 * @brief 是否正在下载视频
 */
@property (nonatomic, readwrite, assign) BOOL isDownloading;

@property (nonatomic, strong) MXVideoMessage *message;

@end

@implementation MXVideoCellModel

#pragma initialize
/**
 *  根据MXMessage内容来生成cell model
 */
- (MXVideoCellModel *)initCellModelWithMessage:(MXVideoMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MXCellModelDelegate>)delegate {
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate  = delegate;
        self.message = message;
        self.videoPath = message.videoPath;
        self.videoServerPath = message.videoUrl;
        self.sendStatus = message.sendStatus;
        self.isDownloading = false;
        self.cellFromType = message.fromType == MXChatMessageIncoming ? MXChatCellIncoming : MXChatCellOutgoing;
        if (message.userAvatarImage) {
            self.avatarImage = message.userAvatarImage;
        } else if (message.userAvatarPath.length > 0) {
            self.avatarPath = message.userAvatarPath;
            //这里使用Mixdesk接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MIXDESK_SDK
            [MXServiceToViewInterface downloadMediaWithUrlString:message.userAvatarPath progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.avatarImage = [UIImage imageWithData:mediaData];
                } else {
                    self.avatarImage = message.fromType == MXChatMessageIncoming ? [MXChatViewConfig sharedConfig].incomingDefaultAvatarImage : [MXChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.message.messageId];
                    }
                }
            }];
#else
            __block UIImageView *tempImageView = [UIImageView new];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.userAvatarPath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                self.avatarImage = tempImageView.image.copy;
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        //通知ViewController去刷新tableView
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.avatarImage = [MXChatViewConfig sharedConfig].incomingDefaultAvatarImage;
            if (message.fromType == MXChatMessageOutgoing) {
                self.avatarImage = [MXChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
            }
        }
        
        // 判断是否缓存了视频
        if (message.videoPath.length > 0 && [MXChatFileUtil fileExistsAtPath:message.videoPath isDirectory:false]) {
            //默认cell高度为图片显示的最大高度
            self.cellHeight = cellWidth / 2;
            self.thumbnail = [MXChatFileUtil getLocationVideoPreViewImage:[NSURL fileURLWithPath:message.videoPath]];
            [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
        } else if (message.thumbnailUrl.length > 0) {
            //这里使用Mixdesk接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MIXDESK_SDK
            [MXServiceToViewInterface downloadMediaWithUrlString:message.thumbnailUrl progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.thumbnail = [UIImage imageWithData:mediaData];
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.thumbnail = [MXChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.message.messageId];
                    }
                }
            }];
#else
            //非MixdeskSDK用户，使用了SDWebImage来做图片缓存
            __block UIImageView *tempImageView = [[UIImageView alloc] init];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.thumbnailUrl] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    self.thumbnail = tempImageView.image.copy;
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.thumbnail = [MXChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.thumbnail = [MXChatViewConfig sharedConfig].imageLoadErrorImage;
            [self setModelsWithContentImage:self.thumbnail cellFromType:message.fromType cellWidth:cellWidth];
        }
    }
    return self;
}

- (void)startDownloadMediaCompletion:(void (^)(NSString * _Nonnull))completion {
#ifdef INCLUDE_MIXDESK_SDK
    __weak typeof(self) weakSelf = self;
    [MXServiceToViewInterface downloadMediaWithUrlString:self.videoServerPath progress:^(float progress) {
        if (!weakSelf.isDownloading && progress != 1) {
            weakSelf.isDownloading = YES;
            if (weakSelf.delegate) {
                if ([weakSelf.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                    [weakSelf.delegate didUpdateCellDataWithMessageId:weakSelf.message.messageId];
                }
            }
        }
        weakSelf.progressBlock(progress);
    } completion:^(NSData *mediaData, NSError *error) {
        if (mediaData) {
            NSString *mediaPath = [MXChatFileUtil getVideoCachePathWithServerUrl:weakSelf.videoServerPath];
            if (![MXChatFileUtil fileExistsAtPath:mediaPath isDirectory:NO]) {
                [[NSFileManager defaultManager] createFileAtPath:mediaPath contents:mediaData attributes:nil];
            }
            weakSelf.message.videoPath = mediaPath;
            if (!weakSelf.isDownloading) {
                completion(mediaPath);
            }
        } else {
            [MXToast showToast:[MXBundleUtil localizedStringForKey:@"display_video_expired"] duration:1.5 window:[UIApplication sharedApplication].keyWindow];
        }
        weakSelf.isDownloading = NO;
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                [self.delegate didUpdateCellDataWithMessageId:self.message.messageId];
            }
        }
    }];
#else
    //非MixdeskSDK用户
    
#endif
}

//根据气泡中的图片生成其他model
- (void)setModelsWithContentImage:(UIImage *)contentImage
                          cellFromType:(MXChatMessageFromType)cellFromType
                        cellWidth:(CGFloat)cellWidth
{
    //限定图片的最大直径
    CGFloat maxContentImageWide = ceil(cellWidth / 2);  //限定图片的最大直径
    CGSize contentImageSize = contentImage ? contentImage.size : CGSizeMake(40, 30);

    //先限定图片宽度来计算高度
    CGFloat imageWidth = contentImageSize.width < maxContentImageWide ? contentImageSize.width : maxContentImageWide;
    CGFloat imageHeight = imageWidth * contentImageSize.height/contentImageSize.width;

    //根据消息的来源，进行处理
    UIImage *bubbleImage = [MXChatViewConfig sharedConfig].incomingBubbleImage;
    if ([MXChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [MXImageUtil convertImageColorWithImage:bubbleImage toColor:[MXChatViewConfig sharedConfig].incomingBubbleColor];
    }

    if (cellFromType == MXChatMessageOutgoing) {
        //发送出去的消息
        self.cellFromType = MXChatCellOutgoing;
        bubbleImage = [MXChatViewConfig sharedConfig].outgoingBubbleImage;
        if ([MXChatViewConfig sharedConfig].outgoingBubbleColor) {
            bubbleImage = [MXImageUtil convertImageColorWithImage:bubbleImage toColor:[MXChatViewConfig sharedConfig].outgoingBubbleColor];
        }
        //头像的frame
        if ([MXChatViewConfig sharedConfig].enableOutgoingAvatar) {
            self.avatarFrame = CGRectMake(cellWidth-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarDiameter, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }

        //content内容
        self.contentImageViewFrame = CGRectMake(kMXCellBubbleToImageSpacing, kMXCellBubbleToImageSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleFrame = CGRectMake(
                                           cellWidth - self.avatarFrame.size.width - kMXCellAvatarToHorizontalEdgeSpacing - kMXCellAvatarToBubbleSpacing - imageWidth - 2 * kMXCellBubbleToImageSpacing,
                                           kMXCellAvatarToVerticalEdgeSpacing,
                                           imageWidth + 2 * kMXCellBubbleToImageSpacing,
                                           imageHeight + kMXCellBubbleToImageSpacing * 2);
    } else {
        //收到的消息
        self.cellFromType = MXChatCellIncoming;
        //头像的frame
        if ([MXChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        self.contentImageViewFrame = CGRectMake(kMXCellBubbleToImageSpacing, kMXCellBubbleToImageSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleFrame = CGRectMake(
                                           self.avatarFrame.origin.x+self.avatarFrame.size.width+kMXCellAvatarToBubbleSpacing,
                                           self.avatarFrame.origin.y,
                                           imageWidth + kMXCellBubbleToImageSpacing * 2,
                                           imageHeight + kMXCellBubbleToImageSpacing * 2);
    }

    //playbtn的frame
    self.playBtnFrame = CGRectMake(self.bubbleFrame.size.width/2-kMXCellPlayBtnHeight/2, self.bubbleFrame.size.height/2-kMXCellPlayBtnHeight/2, kMXCellPlayBtnHeight, kMXCellPlayBtnHeight);
    
    //发送消息的indicator的frame
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter)];
    self.sendingIndicatorFrame = CGRectMake(self.bubbleFrame.origin.x-kMXCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleFrame.origin.y+self.bubbleFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    
    //发送失败的图片frame
    UIImage *failureImage = [MXChatViewConfig sharedConfig].messageSendFailureImage;
    CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
    self.sendFailureFrame = CGRectMake(self.bubbleFrame.origin.x-kMXCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleFrame.origin.y+self.bubbleFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);

    //计算cell的高度
    self.cellHeight = self.bubbleFrame.origin.y + self.bubbleFrame.size.height + kMXCellAvatarToVerticalEdgeSpacing;

}

#pragma MXCellModelProtocol
- (CGFloat)getCellHeight {
    return self.cellHeight;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MXChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MXVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.message.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.message.messageId;
}

- (NSString *)getMessageConversionId {
    return self.message.conversionId;
}

- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.message.messageId = messageId;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.message.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    [self setModelsWithContentImage:self.thumbnail cellFromType:(MXChatMessageFromType)self.cellFromType cellWidth:cellWidth];
}

- (void)updateMediaServerPath:(NSString *)serverPath {
    self.videoPath = [MXChatFileUtil getVideoCachePathWithServerUrl:serverPath];
}

@end
