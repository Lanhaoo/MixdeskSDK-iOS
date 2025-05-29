//
//  MXCardCellModel.m
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXCardCellModel.h"
#import "MXCardMessageCell.h"
#import "TTTAttributedLabel.h"
#import "MXServiceToViewInterface.h"
#import "MXChatViewConfig.h"
#import "MXImageUtil.h"


@interface MXCardCellModel ()

/**
 * @brief cell中消息的id
 */
@property (nonatomic, readwrite, strong) NSString *messageId;

@property (nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 发送者的头像Path
 */
@property (nonatomic, readwrite, copy) NSString *avatarPath;

/**
 * @brief 发送者的头像的图片名字
 */
@property (nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 聊天气泡的image
 */
@property (nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 消息气泡的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleImageFrame;

/**
 * @brief 消息气泡中的文字的frame
 */
@property (nonatomic, readwrite, assign) CGRect textLabelFrame;

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
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

/**
 * @brief cell的高度
 */
@property (nonatomic, readwrite, assign) CGFloat cellHeight;

@property (nonatomic, strong) TTTAttributedLabel *textLabelForHeightCalculation;

@end


@implementation MXCardCellModel


- (MXCardCellModel *)initCellModelWithMessage:(MXCardMessage *)message
                                    cellWidth:(CGFloat)cellWidth delegate:(id<MXCellModelDelegate>)delegator
{
    if (self = [super init]) {
        self.textLabelForHeightCalculation = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        self.textLabelForHeightCalculation.numberOfLines = 0;
        self.conversionId = message.conversionId;
        self.messageId = message.messageId;
        self.date = message.date;
        self.cardData = message.cardData;
        self.cellHeight = 50;
        self.delegate = delegator;
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

        // 固定宽度
        CGFloat messageTextWidth = 240;
        //内容高度
        __block CGFloat messageTextHeight = 60;
        NSArray *cardArr = message.cardData;
        [cardArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MXCardInfo *info = obj;
            if (info.cardType == MXMessageCardTypeRadio || info.cardType == MXMessageCardTypeCheckbox) {
                messageTextHeight += 40 + 35*info.metaData.count;
            }else{
                messageTextHeight += 70;
            }
        }];

        //气泡高度
        CGFloat bubbleHeight = messageTextHeight + kMXCellBubbleToTextVerticalSpacing * 2;
        //气泡宽度
        CGFloat bubbleWidth = messageTextWidth + kMXCellBubbleToTextHorizontalLargerSpacing + kMXCellBubbleToTextHorizontalSmallerSpacing;

        //根据消息的来源，进行处理
        UIImage *bubbleImage = [MXChatViewConfig sharedConfig].incomingBubbleImage;
        if ([MXChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [MXImageUtil convertImageColorWithImage:bubbleImage toColor:[MXChatViewConfig sharedConfig].incomingBubbleColor];
        }
        if (message.fromType == MXChatMessageOutgoing) {
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
                self.avatarFrame = CGRectMake(cellWidth-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarDiameter, kMXCellAvatarToVerticalEdgeSpacing, 0, 0);
            }
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarToBubbleSpacing-bubbleWidth, kMXCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
            //文字的frame
            self.textLabelFrame = CGRectMake(kMXCellBubbleToTextHorizontalSmallerSpacing, kMXCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
        } else {
            //收到的消息
            self.cellFromType = MXChatCellIncoming;

            //头像的frame
            if ([MXChatViewConfig sharedConfig].enableIncomingAvatar) {
                self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
            } else {
                self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing, kMXCellAvatarToVerticalEdgeSpacing, 0, 0);
            }
            //气泡的frame
            self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMXCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
            //文字的frame
            self.textLabelFrame = CGRectMake(kMXCellBubbleToTextHorizontalLargerSpacing, kMXCellBubbleToTextVerticalSpacing, messageTextWidth, messageTextHeight);
        }

        //气泡图片
        self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[MXChatViewConfig sharedConfig].bubbleImageStretchInsets];

        //发送消息的indicator的frame
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter)];
        self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);

        //发送失败的图片frame
        UIImage *failureImage = [MXChatViewConfig sharedConfig].messageSendFailureImage;
        CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
        self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);

        //计算cell的高度
        
        self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kMXCellAvatarToVerticalEdgeSpacing;
        
    }
    return self;
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (MXChatBaseCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MXCardMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (CGFloat)getCellHeight {
    return self.cellHeight > 0 ? self.cellHeight : 0;
}


- (NSString *)getCellMessageId {
    return self.messageId;
}

- (NSString *)getMessageConversionId {
    return self.conversionId;
}

- (NSDate *)getCellDate {
    return self.date;
}

- (BOOL)isServiceRelatedCell {
    return true;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
}




@end
