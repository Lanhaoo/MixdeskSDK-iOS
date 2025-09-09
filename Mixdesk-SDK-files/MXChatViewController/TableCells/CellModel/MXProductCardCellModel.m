//
//  MXProductCardCellModel.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/9/2.
//  Copyright © 2021 2020 Mixdesk. All rights reserved.
//

#import "MXProductCardCellModel.h"
#import "MXServiceToViewInterface.h"
#import "MXImageUtil.h"
#import "MXProductCardMessageCell.h"
#ifndef INCLUDE_MIXDESK_SDK
#import "UIImageView+WebCache.h"
#endif

/**
 * 聊天气泡和内容的留白间距
 */
static CGFloat const kMXCellBubbleToContentSpacing = 12.0;

/**
 * 文字内容的行间隔
 */
static CGFloat const kMXCellTextContentSpacing = 5.0;

/**
 * 商品title内容的高度
 */
static CGFloat const kMXCellTitleHeigh = 20.0;

/**
 * 商品描述内容的高度
 */
static CGFloat const kMXCellDescriptionHeigh = 35.0;

/**
 * 商品销售量内容的高度
 */
static CGFloat const kMXCellSaleCountHeigh = 18.0;

/**
 * 商品链接提示内容的宽度
 */
static CGFloat const kMXCellLinkWidth = 100.0;

/**
 * 图片的高宽比,宽4高3
 */
static CGFloat const kMXCellImageRatio = 0.75;

@interface MXProductCardCellModel()

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

/**
 * @brief 图片image(当imagePath不存在时使用)
 */
@property (nonatomic, readwrite, strong) UIImage *image;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 商品的title
 */
@property (nonatomic, readwrite, copy) NSString *title;

/**
 * @brief 商品的描述内容
 */
@property (nonatomic, readwrite, copy) NSString *desc;

/**
 * @brief 商品的销售量
 */
@property (nonatomic, readwrite, assign) long saleCount;

/**
 * @brief 商品的url
 */
@property (nonatomic, readwrite, copy) NSString *productUrl;

/**
 * @brief 商品图片的url
 */
@property (nonatomic, readwrite, copy) NSString *productPictureUrl;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief bubble中的imageView的frame
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief bubble中的商品title的frame
 */
@property (nonatomic, readwrite, assign) CGRect titleFrame;

/**
 * @brief bubble中的商品描述内容的frame
 */
@property (nonatomic, readwrite, assign) CGRect descriptionFrame;

/**
 * @brief bubble中的商品销售量的frame
 */
@property (nonatomic, readwrite, assign) CGRect saleCountFrame;

/**
 * @brief bubble中查看详情的frame
 */
@property (nonatomic, readwrite, assign) CGRect linkFrame;

/**
 * @brief 消息背景框的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MXChatCellFromType cellFromType;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

/**
 * @brief 已读状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect readStatusIndicatorFrame;

@end

@implementation MXProductCardCellModel

#pragma initialize
/**
 *  根据MXMessage内容来生成cell model
 */
- (MXProductCardCellModel *)initCellModelWithMessage:(MXProductCardMessage *)message
                                           cellWidth:(CGFloat)cellWidth
                                            delegate:(id<MXCellModelDelegate>)delegate
{
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate = delegate;
        self.sendStatus = message.sendStatus;
        self.productPictureUrl = message.pictureUrl;
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.readStatus = message.readStatus;
        self.date = message.date;
        self.title = message.title;
        self.productUrl = message.productUrl;
        self.desc = message.desc;
        self.saleCount = message.salesCount;
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
        if (message.pictureUrl.length > 0) {
            
            //默认cell高度为图片显示的最大高度
            self.cellHeight = cellWidth / 2;
            
            //                [self setModelsWithContentImage:[MXChatViewConfig sharedConfig].incomingBubbleImage cellFromType:message.fromType cellWidth:cellWidth];
            
            //这里使用Mixdesk接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MIXDESK_SDK
            [MXServiceToViewInterface downloadMediaWithUrlString:message.pictureUrl progress:^(float progress) {
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
            [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.pictureUrl] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
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
    
    //图片宽度固定
    CGFloat imageWidth = maxContentImageWide;
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
        
        //商品图片的frame
        self.contentImageViewFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellBubbleToContentSpacing, imageWidth, imageHeight);
        //商品title的frame
        self.titleFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellBubbleToContentSpacing + CGRectGetMaxY(self.contentImageViewFrame), imageWidth, kMXCellTitleHeigh);
        //商品描述内容的frame
        self.descriptionFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellTextContentSpacing + CGRectGetMaxY(self.titleFrame), imageWidth, kMXCellDescriptionHeigh);
        //商品销量的frame
        self.saleCountFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellTextContentSpacing + CGRectGetMaxY(self.descriptionFrame), imageWidth / 2.0, kMXCellSaleCountHeigh);
        //商品详情链接提示的frame
        self.linkFrame = CGRectMake(kMXCellBubbleToContentSpacing + imageWidth - kMXCellLinkWidth , CGRectGetMinY(self.saleCountFrame), kMXCellLinkWidth, kMXCellSaleCountHeigh);
        
        //气泡的frame
        self.bubbleFrame = CGRectMake(cellWidth - self.avatarFrame.size.width - kMXCellAvatarToHorizontalEdgeSpacing - kMXCellAvatarToBubbleSpacing - imageWidth - 2 * kMXCellBubbleToContentSpacing,
                                      kMXCellAvatarToVerticalEdgeSpacing,
                                      imageWidth + 2 * kMXCellBubbleToContentSpacing,
                                      imageHeight + kMXCellBubbleToContentSpacing * 3 + kMXCellTextContentSpacing * 2 + kMXCellTitleHeigh + kMXCellDescriptionHeigh + kMXCellSaleCountHeigh);
    } else {
        //收到的消息
        self.cellFromType = MXChatCellIncoming;
        
        //头像的frame
        if ([MXChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        //商品图片的frame
        self.contentImageViewFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellBubbleToContentSpacing, imageWidth, imageHeight);
        //商品title的frame
        self.titleFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellBubbleToContentSpacing + CGRectGetMaxY(self.contentImageViewFrame), imageWidth, kMXCellTitleHeigh);
        //商品描述内容的frame
        self.descriptionFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellTextContentSpacing + CGRectGetMaxY(self.titleFrame), imageWidth, kMXCellDescriptionHeigh);
        //商品销量的frame
        self.saleCountFrame = CGRectMake(kMXCellBubbleToContentSpacing, kMXCellTextContentSpacing + CGRectGetMaxY(self.descriptionFrame), imageWidth / 2.0, kMXCellSaleCountHeigh);
        //商品详情链接提示的frame
        self.linkFrame = CGRectMake(kMXCellBubbleToContentSpacing + imageWidth - kMXCellLinkWidth , CGRectGetMinY(self.saleCountFrame), kMXCellLinkWidth, kMXCellSaleCountHeigh);
        //气泡的frame
        self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMXCellAvatarToBubbleSpacing,
                                      self.avatarFrame.origin.y,
                                      imageWidth + 2 * kMXCellBubbleToContentSpacing,
                                      imageHeight + kMXCellBubbleToContentSpacing * 3 + kMXCellTextContentSpacing * 2 + kMXCellTitleHeigh + kMXCellDescriptionHeigh + kMXCellSaleCountHeigh);
    }
    
    //发送消息的indicator的frame
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter)];
    self.sendingIndicatorFrame = CGRectMake(self.bubbleFrame.origin.x-kMXCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleFrame.origin.y+self.bubbleFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    
    //发送失败的图片frame
    UIImage *failureImage = [MXChatViewConfig sharedConfig].messageSendFailureImage;
    CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
    self.sendFailureFrame = CGRectMake(self.bubbleFrame.origin.x-kMXCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleFrame.origin.y+self.bubbleFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);
    
    //已读状态指示器的frame (仅对发送的消息显示)
    CGFloat statusIndicatorSize = 12.0; // 状态指示器大小
    if (self.cellFromType == MXChatCellOutgoing) {
        // 状态指示器放在气泡左边5像素，垂直居中对齐气泡底部
        self.readStatusIndicatorFrame = CGRectMake(CGRectGetMinX(self.bubbleFrame) - statusIndicatorSize - 5,
                                                  CGRectGetMaxY(self.bubbleFrame) - statusIndicatorSize,
                                                  statusIndicatorSize,
                                                  statusIndicatorSize);
    } else {
        // 接收的消息不显示状态指示器
        self.readStatusIndicatorFrame = CGRectZero;
    }
    
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
    return [[MXProductCardMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (NSString *)getMessageReadStatus {
    return self.readStatus;
}

- (NSString *)getMessageConversionId {
    return self.conversionId;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
}

- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellReadStatus:(NSNumber *)readStatus {
    self.readStatus = readStatus;
}

- (void)updateCellConversionId:(NSString *)conversionId {
    self.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
    self.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    [self setModelsWithContentImage:self.image cellFromType:(MXChatMessageFromType)self.cellFromType cellWidth:cellWidth];
}

@end
