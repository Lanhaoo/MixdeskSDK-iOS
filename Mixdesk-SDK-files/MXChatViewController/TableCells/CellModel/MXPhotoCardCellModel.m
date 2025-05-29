//
//  MXPhotoCardCellModel.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXPhotoCardCellModel.h"
#import "MXServiceToViewInterface.h"
#import "MXImageUtil.h"
#ifndef INCLUDE_MIXDESK_SDK
#import "UIImageView+WebCache.h"
#endif
/**
 * 聊天气泡和其中的图片垂直间距
 */
static CGFloat const kMXCellBubbleToImageSpacing = 12.0;

/**
 * 图片的高宽比,宽4高3
 */
static CGFloat const kMXCellImageRatio = 0.75;

@interface MXPhotoCardCellModel()

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 用户名字，暂时没用
 */
@property (nonatomic, readwrite, copy) NSString *userName;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 图片image
 */
@property (nonatomic, readwrite, strong) UIImage *image;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 操作目标的Path
 */
@property (nonatomic, readwrite, copy) NSString *targetUrl;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * bubble中的imageView的frame
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 读取照片的指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MXChatCellFromType cellFromType;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

@end

@implementation MXPhotoCardCellModel

#pragma initialize
/**
 *  根据MXMessage内容来生成cell model
 */
- (MXPhotoCardCellModel *)initCellModelWithMessage:(MXPhotoCardMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MXCellModelDelegate>)delegate {
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate = delegate;
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.date = message.date;
        self.targetUrl = message.targetUrl;
        self.avatarPath = @"";
        self.cellHeight = 44.0;
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
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
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
        
        //内容图片
        if (message.imagePath.length > 0) {
            
            //默认cell高度为图片显示的最大高度
            self.cellHeight = cellWidth / 2;
            
            //                [self setModelsWithContentImage:[MXChatViewConfig sharedConfig].incomingBubbleImage cellFromType:message.fromType cellWidth:cellWidth];
            
            //这里使用Mixdesk接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MIXDESK_SDK
            [MXServiceToViewInterface downloadMediaWithUrlString:message.imagePath progress:^(float progress) {
            } completion:^(NSData *mediaData, NSError *error) {
                if (mediaData && !error) {
                    self.image = [UIImage imageWithData:mediaData];
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.image = [MXChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#else
            //非MixdeskSDK用户，使用了SDWebImage来做图片缓存
            __block UIImageView *tempImageView = [[UIImageView alloc] init];
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.imagePath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    self.image = tempImageView.image.copy;
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                } else {
                    self.image = [MXChatViewConfig sharedConfig].imageLoadErrorImage;
                    [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
                }
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                    }
                }
            }];
#endif
        } else {
            self.image = [MXChatViewConfig sharedConfig].imageLoadErrorImage;
            [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
        }
    } else {
        [self setModelsWithContentImage:self.image cellFromType:message.fromType cellWidth:cellWidth];
    }
    return self;
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
    CGFloat imageHeight = imageWidth * kMXCellImageRatio;
    
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
    
    //loading image的indicator
    self.loadingIndicatorFrame = CGRectMake(self.bubbleFrame.size.width/2-kMXCellIndicatorDiameter/2, self.bubbleFrame.size.height/2-kMXCellIndicatorDiameter/2, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter);
    
    //计算cell的高度
    self.cellHeight = self.bubbleFrame.origin.y + self.bubbleFrame.size.height + kMXCellAvatarToVerticalEdgeSpacing;

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
    return [[MXPhotoCardMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (NSString *)getCellMessageId {
    return self.messageId;
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

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
//    if (self.cellFromType == MXChatCellOutgoing) {
//        //头像的frame
//        if ([MXChatViewConfig sharedConfig].enableOutgoingAvatar) {
//            self.avatarFrame = CGRectMake(cellWidth-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarDiameter, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
//        } else {
//            self.avatarFrame = CGRectMake(0, 0, 0, 0);
//        }
//        //气泡的frame
//        self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarToBubbleSpacing-self.bubbleImageFrame.size.width, kMXCellAvatarToVerticalEdgeSpacing, self.bubbleImageFrame.size.width, self.bubbleImageFrame.size.height);
//        //发送指示器的frame
//        self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-self.sendingIndicatorFrame.size.width, self.sendingIndicatorFrame.origin.y, self.sendingIndicatorFrame.size.width, self.sendingIndicatorFrame.size.height);
//        //发送出错图片的frame
//        self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-self.sendFailureFrame.size.width, self.sendFailureFrame.origin.y, self.sendFailureFrame.size.width, self.sendFailureFrame.size.height);
//    }
    
    [self setModelsWithContentImage:self.image cellFromType:(MXChatMessageFromType)self.cellFromType cellWidth:cellWidth];
}


@end

