//
//  MXImageCellModel.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXImageCellModel.h"
#import "MXChatBaseCell.h"
#import "MXImageMessageCell.h"
#import "MXChatViewConfig.h"
#import "MXImageUtil.h"
#import "MXServiceToViewInterface.h"
#import "MXImageViewerViewController.h"
#import "UIViewController+MXHieriachy.h"
#ifndef INCLUDE_MIXDESK_SDK
#import "UIImageView+WebCache.h"
#endif
@interface MXImageCellModel()

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
 * @brief 图片path
 */
//@property (nonatomic, readwrite, copy) NSString *imagePath;

/**
 * @brief 图片image(当imagePath不存在时使用)
 */
@property (nonatomic, readwrite, strong) UIImage *image;

/**
 * @brief 消息的时间
 */
@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 聊天气泡的image（该气泡image已经进行了resize）
 */
@property (nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 快捷按钮视图
 */
@property (nonatomic, readwrite, strong) MXQuickBtnView *cacheQuickBtnView;

/**
 * @brief 快捷按钮数据
 */
@property (nonatomic, readwrite, strong) NSArray *quickBtns;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleImageFrame;

/**
 * bubble中的imageView的frame，该frame是在关闭bubble mask情况下生效
 */
@property (nonatomic, readwrite, assign) CGRect contentImageViewFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 读取照片的指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MXChatCellFromType cellFromType;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

@end

@implementation MXImageCellModel

#pragma initialize
/**
 *  根据MXMessage内容来生成cell model
 */
- (MXImageCellModel *)initCellModelWithMessage:(MXImageMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MXCellModelDelegate>)delegator{
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.delegate = delegator;
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.sendStatus = message.sendStatus;
        self.date = message.date;
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
        self.image = message.image;
        
        // 获取快捷按钮数据
        self.quickBtns = message.quickBtns;
        
        if (!message.image) {
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
        
    }
    return self;
}

//根据气泡中的图片生成其他model
- (void)setModelsWithContentImage:(UIImage *)contentImage
                          cellFromType:(MXChatMessageFromType)cellFromType
                        cellWidth:(CGFloat)cellWidth
{
    //限定图片的最大直径
    CGFloat maxBubbleDiameter = ceil(cellWidth / 2);  //限定图片的最大直径
    CGSize contentImageSize = contentImage ? contentImage.size : CGSizeMake(20, 20);
    
    //先限定图片宽度来计算高度
    CGFloat imageWidth = contentImageSize.width < maxBubbleDiameter ? contentImageSize.width : maxBubbleDiameter;
    CGFloat imageHeight = ceil(contentImageSize.height / contentImageSize.width * imageWidth);
    //判断如果气泡高度计算结果超过图片的最大直径，则限制高度
    if (imageHeight > maxBubbleDiameter) {
        imageHeight = maxBubbleDiameter;
        imageWidth = ceil(contentImageSize.width / contentImageSize.height * imageHeight);
    }
    
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
        self.contentImageViewFrame = CGRectMake(kMXCellBubbleToImageHorizontalSmallerSpacing, kMXCellBubbleToImageVerticalSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(
                                           cellWidth - self.avatarFrame.size.width - kMXCellAvatarToHorizontalEdgeSpacing - kMXCellAvatarToBubbleSpacing - imageWidth - kMXCellBubbleToImageHorizontalSmallerSpacing - kMXCellBubbleToImageHorizontalLargerSpacing,
                                           kMXCellAvatarToVerticalEdgeSpacing,
                                           imageWidth + kMXCellBubbleToImageHorizontalSmallerSpacing + kMXCellBubbleToImageHorizontalLargerSpacing,
                                           imageHeight + kMXCellBubbleToImageVerticalSpacing * 2);
        if ([MXChatViewConfig sharedConfig].enableMessageImageMask) {
            self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarToBubbleSpacing-imageWidth, kMXCellAvatarToVerticalEdgeSpacing, imageWidth, imageHeight);
        }
    } else {
        //收到的消息
        self.cellFromType = MXChatCellIncoming;
        
        //头像的frame
        if ([MXChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        self.contentImageViewFrame = CGRectMake(kMXCellBubbleToImageHorizontalLargerSpacing, kMXCellBubbleToImageVerticalSpacing, imageWidth, imageHeight);
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(
                                           self.avatarFrame.origin.x+self.avatarFrame.size.width+kMXCellAvatarToBubbleSpacing,
                                           self.avatarFrame.origin.y,
                                           imageWidth + kMXCellBubbleToImageHorizontalSmallerSpacing + kMXCellBubbleToImageHorizontalLargerSpacing,
                                           imageHeight + kMXCellBubbleToImageVerticalSpacing * 2);
        if ([MXChatViewConfig sharedConfig].enableMessageImageMask) {
            self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMXCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, imageWidth, imageHeight);
        }
    }
    
    //loading image的indicator
    self.loadingIndicatorFrame = CGRectMake(self.bubbleImageFrame.size.width/2-kMXCellIndicatorDiameter/2, self.bubbleImageFrame.size.height/2-kMXCellIndicatorDiameter/2, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter);
    
    //气泡图片
    self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[MXChatViewConfig sharedConfig].bubbleImageStretchInsets];
    
    //发送消息的indicator的frame
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter)];
    self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    
    //发送失败的图片frame
    UIImage *failureImage = [MXChatViewConfig sharedConfig].messageSendFailureImage;
    CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
    self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);
    
    //初始化快捷按钮视图
    CGFloat quickBtnHeight = 0;
    if (self.quickBtns && self.quickBtns.count > 0) {
        // 使用与富文本消息相同的最大宽度计算方式
        CGFloat maxAvailableWidth = [UIScreen mainScreen].bounds.size.width - 40;
        
        self.cacheQuickBtnView = [[MXQuickBtnView alloc] initWithQuickBtns:self.quickBtns
                                                         maxWidth:maxAvailableWidth
                                                           convId:self.messageId];
        quickBtnHeight = [self.cacheQuickBtnView getViewHeight] + 8.0; // 8.0是间距
    }
    
    //计算cell的高度
    self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kMXCellAvatarToVerticalEdgeSpacing + quickBtnHeight;

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
    return [[MXImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
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

- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage {
    if (self.cellFromType == MXChatCellOutgoing) {
        self.avatarImage = avatarImage;
    }
}

- (void)showImageViewerFromRect:(CGRect)rect {
    MXImageViewerViewController *viewerVC = [MXImageViewerViewController new];
    viewerVC.images = @[self.image];
    
    __weak MXImageViewerViewController *wViewerVC = viewerVC;
    [viewerVC setSelection:^(NSUInteger index) {
        __strong MXImageViewerViewController *sViewerVC = wViewerVC;
        [sViewerVC dismiss];
    }];
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [viewerVC showOn:[UIViewController mx_topMostViewController] fromRectArray:[NSArray arrayWithObject:[NSValue valueWithCGRect:rect]]];
}

@end
