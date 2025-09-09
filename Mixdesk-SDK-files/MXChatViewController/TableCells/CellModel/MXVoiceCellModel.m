//
//  MXVoiceCellModel.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXVoiceCellModel.h"
#import "MXChatBaseCell.h"
#import "MXVoiceMessageCell.h"
#import "MXChatViewConfig.h"
#import "MXStringSizeUtil.h"
#import "MXImageUtil.h"
#import "MXAssetUtil.h"
#import "MIXDESK_VoiceConverter.h"
#import "MXServiceToViewInterface.h"
#ifndef INCLUDE_MIXDESK_SDK
#import "UIImageView+WebCache.h"
#endif

/**
 * 语音播放图片与聊天气泡的间距
 */
static CGFloat const kMXCellVoiceImageToBubbleSpacing = 24.0;
/**
 * 语音时长label与气泡的间隔
 */
static CGFloat const kMXCellVoiceDurationLabelToBubbleSpacing = 8.0;
/**
 * 语音未播放的按钮的直径
 */
static CGFloat const kMXCellVoiceNotPlayPointViewDiameter = 8.0;

@interface MXVoiceCellModel()

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
 * @brief 语音data
 */
@property (nonatomic, readwrite, copy) NSData *voiceData;

/**
 * @brief 语音的时长
 */
@property (nonatomic, readwrite, assign) NSInteger voiceDuration;

/**
 * @brief 消息的时间
 */
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
 * @brief 消息气泡button的frame
 */
@property (nonatomic, readwrite, assign) CGRect bubbleImageFrame;

/**
 * @brief 发送者的头像frame
 */
@property (nonatomic, readwrite, assign) CGRect avatarFrame;

/**
 * @brief 发送状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendingIndicatorFrame;

/**
 * @brief 读取语音数据的指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect loadingIndicatorFrame;

/**
 * @brief 语音时长的frame
 */
@property (nonatomic, readwrite, assign) CGRect durationLabelFrame;

/**
 * @brief 语音图片的frame
 */
@property (nonatomic, readwrite, assign) CGRect voiceImageFrame;

/**
 * @brief 发送出错图片的frame
 */
@property (nonatomic, readwrite, assign) CGRect sendFailureFrame;

/**
 * @brief 语音未播放的小红点view的frame
 */
@property (nonatomic, readwrite, assign) CGRect notPlayViewFrame;

/**
 * @brief 消息的来源类型
 */
@property (nonatomic, readwrite, assign) MXChatCellFromType cellFromType;

/**
 * @brief 语音是否加载成功
 */
@property (nonatomic, readwrite, assign) BOOL isLoadVoiceSuccess;

/**
 * @brief cell中消息的会话id
 */
@property (nonatomic, readwrite, strong) NSString *conversionId;

/**
 * @brief 已读状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect readStatusIndicatorFrame;

@end

@implementation MXVoiceCellModel {
    NSTimeInterval voiceTimeInterval;
}

- (void)setVoiceHasPlayed {
    self.isPlayed = YES;
    [MXVoiceMessage setVoiceHasPlayedToDBWithMessageId:self.messageId];
}

#pragma initialize
/**
 *  根据MXMessage内容来生成cell model
 */
- (MXVoiceCellModel *)initCellModelWithMessage:(MXVoiceMessage *)message
                                     cellWidth:(CGFloat)cellWidth
                                      delegate:(id<MXCellModelDelegate>)delegator{
    if (self = [super init]) {
        voiceTimeInterval = 0;
        self.delegate = delegator;
        self.messageId = message.messageId;
        self.conversionId = message.conversionId;
        self.sendStatus = message.sendStatus;
        self.readStatus = message.readStatus;
        self.date = message.date;
        self.avatarPath = @"";
        self.cellHeight = 44.0;
        self.isPlayed = message.isPlayed;
        self.isLoadVoiceSuccess = true;
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
        self.voiceDuration = 0;
        
        //获取语音数据
        self.voiceData = message.voiceData;
        if (!self.voiceData) {
            if (message.voicePath.length > 0) {
                //这里使用Mixdesk接口下载多媒体消息的内容，开发者也可以替换成自己的文件缓存策略
#ifdef INCLUDE_MIXDESK_SDK
                [MXServiceToViewInterface downloadMediaWithUrlString:message.voicePath progress:^(float progress) {
                } completion:^(NSData *mediaData, NSError *error) {
                    if (mediaData && !error) {
                        if ([[message.voicePath substringFromIndex:(message.voicePath.length - 3)] isEqualToString:@"amr"]) {
                            NSString *tempPath = [NSString stringWithFormat:@"%@/tempAmr",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]];
                            BOOL createSuccess = [[NSFileManager defaultManager] createFileAtPath:tempPath contents:mediaData attributes:nil];
                            if (!createSuccess) {
                                NSLog(@"failed to create file");
                            }
                            NSString *wavPath = [NSString stringWithFormat:@"%@wav", tempPath];
                            [MIXDESK_VoiceConverter amrToWav:tempPath wavSavePath:wavPath];
                            mediaData = [NSData dataWithContentsOfFile:wavPath];
                            BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
                            if (!removeSuccess) {
                                NSLog(@"failed to remove file");
                            }
                            [[NSFileManager defaultManager] removeItemAtPath:wavPath error:nil];
                        }
                        self.voiceData = mediaData;
                        voiceTimeInterval = [MXChatFileUtil getAudioDurationWithData:mediaData];
                        [self setModelsWithMessage:message cellWidth:cellWidth isLoadVoiceSuccess:true];
                    } else {
                        [self setModelsWithMessage:message cellWidth:cellWidth isLoadVoiceSuccess:false];
                    }
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                            [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                        }
                    }
                }];
#else
                //新建线程读取远程图片
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSError *error;
                    //这里开发者可以使用自己的文件缓存策略
                    NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.voicePath] options:NSDataReadingMappedIfSafe error:&error];
                    //Mixdesk服务端传给SDK的语音格式是MP3，iPhone可以直接播放；开发者可根据自己的服务端情况，将语音转换成iPhone能播放的格式
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            NSLog(@"load voice error = %@", error);
                        }
                        if (voiceData) {
                            self.voiceData = voiceData;
                            voiceTimeInterval = [MXChatFileUtil getAudioDurationWithData:voiceData];
                            [self setModelsWithMessage:message cellWidth:cellWidth isLoadVoiceSuccess:true];
                        } else {
                            [self setModelsWithMessage:message cellWidth:cellWidth isLoadVoiceSuccess:false];
                        }
                        if (self.delegate) {
                            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                            }
                        }
                    });
                });
#endif
            }
            [self setModelsWithMessage:message cellWidth:cellWidth isLoadVoiceSuccess:true];
        } else {
            voiceTimeInterval = [MXChatFileUtil getAudioDurationWithData:self.voiceData];
            [self setModelsWithMessage:message cellWidth:cellWidth isLoadVoiceSuccess:true];
        }
    }
    return self;
}

//根据气泡中的图片生成其他model
- (void)setModelsWithMessage:(MXVoiceMessage *)message
                   cellWidth:(CGFloat)cellWidth
          isLoadVoiceSuccess:(BOOL)isLoadVoiceSuccess
{
    self.isLoadVoiceSuccess = isLoadVoiceSuccess;
    if (!isLoadVoiceSuccess) {
        self.voiceData = [[NSData alloc] init];
    }
    self.voiceDuration = ceilf((CGFloat)voiceTimeInterval);
    //语音图片size
    UIImage *voiceImage;
    if (message.fromType == MXChatMessageOutgoing) {
        voiceImage = isLoadVoiceSuccess ? [MXAssetUtil voiceAnimationGreen3] : [MXAssetUtil voiceAnimationGreenError];
    } else {
        voiceImage = isLoadVoiceSuccess ? [MXAssetUtil voiceAnimationGray3] : [MXAssetUtil voiceAnimationGrayError];
    }
    CGSize voiceImageSize = voiceImage.size;
    
    //气泡高度
    CGFloat bubbleHeight = kMXCellAvatarDiameter;
    
    //根据语音时长来确定气泡宽度
    CGFloat maxBubbleWidth = cellWidth - kMXCellAvatarToHorizontalEdgeSpacing - kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing - kMXCellBubbleMaxWidthToEdgeSpacing;
    CGFloat bubbleWidth = maxBubbleWidth;
    //    if (self.voiceDuration < [MXChatViewConfig sharedConfig].maxVoiceDuration * 2) {
    CGFloat upWidth = floor(cellWidth / 4);   //根据语音时间来递增的基准
    CGFloat voiceWidthScale = self.voiceDuration / [MXChatViewConfig sharedConfig].maxVoiceDuration;
    bubbleWidth = floor(upWidth*voiceWidthScale) + floor(cellWidth/4);
    //    } else {
    //        NSAssert(NO, @"语音超过最大时长！");
    //    }
    
    //语音时长label的宽高
    CGFloat durationTextHeight = [MXStringSizeUtil getHeightForText:[NSString stringWithFormat:@"%d\"", (int)self.voiceDuration] withFont:[UIFont systemFontOfSize:kMXCellVoiceDurationLabelFontSize] andWidth:cellWidth];
    CGFloat durationTextWidth = [MXStringSizeUtil getWidthForText:[NSString stringWithFormat:@"%d\"", (int)self.voiceDuration] withFont:[UIFont systemFontOfSize:kMXCellVoiceDurationLabelFontSize] andHeight:durationTextHeight];
    
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
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarToBubbleSpacing-bubbleWidth, kMXCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
        //语音图片的frame
        self.voiceImageFrame = CGRectMake(self.bubbleImageFrame.size.width-kMXCellVoiceImageToBubbleSpacing-voiceImageSize.width, self.bubbleImageFrame.size.height/2-voiceImageSize.height/2, voiceImageSize.width, voiceImageSize.height);
        //语音时长的frame
        self.durationLabelFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellVoiceDurationLabelToBubbleSpacing-durationTextWidth, self.bubbleImageFrame.origin.y, durationTextWidth, durationTextHeight);
    } else {
        //收到的消息
        self.cellFromType = MXChatCellIncoming;
        //头像的frame
        if ([MXChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMXCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
        //语音图片的frame
        self.voiceImageFrame = CGRectMake(kMXCellVoiceImageToBubbleSpacing, self.bubbleImageFrame.size.height/2-voiceImageSize.height/2, voiceImageSize.width, voiceImageSize.height);
        //语音时长的frame
        self.durationLabelFrame = CGRectMake(self.bubbleImageFrame.origin.x+self.bubbleImageFrame.size.width+kMXCellVoiceDurationLabelToBubbleSpacing, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-durationTextHeight/2, durationTextWidth, durationTextHeight);
        //未播放按钮的frame
        self.notPlayViewFrame = CGRectMake(self.bubbleImageFrame.origin.x + self.bubbleImageFrame.size.width + kMXCellVoiceDurationLabelToBubbleSpacing, self.bubbleImageFrame.origin.y, kMXCellVoiceNotPlayPointViewDiameter, kMXCellVoiceNotPlayPointViewDiameter);
    }
    
    
    //loading image的indicator
    self.loadingIndicatorFrame = CGRectMake(self.bubbleImageFrame.size.width/2-kMXCellIndicatorDiameter/2, self.bubbleImageFrame.size.height/2-kMXCellIndicatorDiameter/2, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter);
    
    //气泡图片
    self.bubbleImage = [bubbleImage resizableImageWithCapInsets:[MXChatViewConfig sharedConfig].bubbleImageStretchInsets];
    
    //发送消息的indicator的frame
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMXCellIndicatorDiameter, kMXCellIndicatorDiameter)];
    self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-indicatorView.frame.size.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-indicatorView.frame.size.height/2, indicatorView.frame.size.width, indicatorView.frame.size.height);
    
    //发送失败的图片frame
    UIImage *failureImage = [MXAssetUtil messageWarningImage];
    CGSize failureSize = CGSizeMake(ceil(failureImage.size.width * 2 / 3), ceil(failureImage.size.height * 2 / 3));
    self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-failureSize.width, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-failureSize.height/2, failureSize.width, failureSize.height);
    
    //计算cell的高度
    self.cellHeight = self.bubbleImageFrame.origin.y + self.bubbleImageFrame.size.height + kMXCellAvatarToVerticalEdgeSpacing;
    
    // 计算已读状态指示器的frame
    [self calculateReadStatusIndicatorFrame];
    
}

- (void)calculateReadStatusIndicatorFrame {
    // 统一设置已读状态指示器的frame
    CGFloat statusIndicatorSize = 12.0; // 状态指示器大小
    if (self.cellFromType == MXChatCellOutgoing) {        
        // 状态指示器放在气泡左下角
        // durationLabel在左上角，状态指示器在左下角，避免重叠
        CGFloat statusIndicatorX = self.bubbleImageFrame.origin.x - statusIndicatorSize - 5;
        CGFloat statusIndicatorY = CGRectGetMaxY(self.bubbleImageFrame) - statusIndicatorSize;
        
        self.readStatusIndicatorFrame = CGRectMake(statusIndicatorX,
                                                  statusIndicatorY,
                                                  statusIndicatorSize,
                                                  statusIndicatorSize);
        } else {
        // 接收的消息不显示状态指示器
        self.readStatusIndicatorFrame = CGRectZero;
    }
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
    return [[MXVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
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

- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus {
    self.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
    self.messageId = messageId;
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
    NSLog(@"Voice updateCellFrameWithCellWidth called with cellWidth: %.2f", cellWidth);
    self.cellWidth = cellWidth;
//    if (self.cellFromType == MXChatCellOutgoing) {
//        //头像的frame
//        if ([MXChatViewConfig sharedConfig].enableOutgoingAvatar) {
//            self.avatarFrame = CGRectMake(cellWidth-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarDiameter, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
//        } else {
//            self.avatarFrame = CGRectMake(0, 0, 0, 0);
//        }
//        
//        
//        //根据语音时长来确定气泡宽度
//        CGFloat maxBubbleWidth = cellWidth - kMXCellAvatarToHorizontalEdgeSpacing - kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing - kMXCellBubbleMaxWidthToEdgeSpacing;
//        CGFloat bubbleWidth = maxBubbleWidth;
//        //    if (self.voiceDuration < [MXChatViewConfig sharedConfig].maxVoiceDuration * 2) {
//        CGFloat upWidth = floor(cellWidth / 4);   //根据语音时间来递增的基准
//        CGFloat voiceWidthScale = self.voiceDuration / [MXChatViewConfig sharedConfig].maxVoiceDuration;
//        bubbleWidth = floor(upWidth*voiceWidthScale) + floor(cellWidth/4);
//        
//        //气泡的frame
//        self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarToBubbleSpacing-bubbleWidth, kMXCellAvatarToVerticalEdgeSpacing, self.bubbleImageFrame.size.width, self.bubbleImageFrame.size.height);
//        //发送指示器的frame
//        self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-self.sendingIndicatorFrame.size.width, self.sendingIndicatorFrame.origin.y, self.sendingIndicatorFrame.size.width, self.sendingIndicatorFrame.size.height);
//        //发送出错图片的frame
//        self.sendFailureFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-self.sendFailureFrame.size.width, self.sendFailureFrame.origin.y, self.sendFailureFrame.size.width, self.sendFailureFrame.size.height);
//        //语音时长的frame
//        self.durationLabelFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellBubbleToIndicatorSpacing-self.durationLabelFrame.size.width, self.durationLabelFrame.origin.y, self.durationLabelFrame.size.width, self.durationLabelFrame.size.height);
//    }
    
    //语音图片size
    UIImage *voiceImage;
    if (self.cellFromType == MXChatMessageOutgoing) {
        voiceImage = self.isLoadVoiceSuccess ? [MXAssetUtil voiceAnimationGreen3] : [MXAssetUtil voiceAnimationGreenError];
    } else {
        voiceImage = self.isLoadVoiceSuccess ? [MXAssetUtil voiceAnimationGray3] : [MXAssetUtil voiceAnimationGrayError];
    }
    CGSize voiceImageSize = voiceImage.size;
    
    //气泡高度
    CGFloat bubbleHeight = kMXCellAvatarDiameter;
    
    //根据语音时长来确定气泡宽度
    CGFloat maxBubbleWidth = cellWidth - kMXCellAvatarToHorizontalEdgeSpacing - kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing - kMXCellBubbleMaxWidthToEdgeSpacing;
    CGFloat bubbleWidth = maxBubbleWidth;
    //    if (self.voiceDuration < [MXChatViewConfig sharedConfig].maxVoiceDuration * 2) {
    CGFloat upWidth = floor(cellWidth / 4);   //根据语音时间来递增的基准
    CGFloat voiceWidthScale = self.voiceDuration / [MXChatViewConfig sharedConfig].maxVoiceDuration;
    bubbleWidth = floor(upWidth*voiceWidthScale) + floor(cellWidth/4);
    //    } else {
    //        NSAssert(NO, @"语音超过最大时长！");
    //    }
    
    //语音时长label的宽高
    CGFloat durationTextHeight = [MXStringSizeUtil getHeightForText:[NSString stringWithFormat:@"%d\"", (int)self.voiceDuration] withFont:[UIFont systemFontOfSize:kMXCellVoiceDurationLabelFontSize] andWidth:cellWidth];
    CGFloat durationTextWidth = [MXStringSizeUtil getWidthForText:[NSString stringWithFormat:@"%d\"", (int)self.voiceDuration] withFont:[UIFont systemFontOfSize:kMXCellVoiceDurationLabelFontSize] andHeight:durationTextHeight];
    
    //根据消息的来源，进行处理
    UIImage *bubbleImage = [MXChatViewConfig sharedConfig].incomingBubbleImage;
    if ([MXChatViewConfig sharedConfig].incomingBubbleColor) {
        bubbleImage = [MXImageUtil convertImageColorWithImage:bubbleImage toColor:[MXChatViewConfig sharedConfig].incomingBubbleColor];
    }
    if (self.cellFromType == MXChatMessageOutgoing) {
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
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(cellWidth-self.avatarFrame.size.width-kMXCellAvatarToHorizontalEdgeSpacing-kMXCellAvatarToBubbleSpacing-bubbleWidth, kMXCellAvatarToVerticalEdgeSpacing, bubbleWidth, bubbleHeight);
        //语音图片的frame
        self.voiceImageFrame = CGRectMake(self.bubbleImageFrame.size.width-kMXCellVoiceImageToBubbleSpacing-voiceImageSize.width, self.bubbleImageFrame.size.height/2-voiceImageSize.height/2, voiceImageSize.width, voiceImageSize.height);
        //语音时长的frame
        self.durationLabelFrame = CGRectMake(self.bubbleImageFrame.origin.x-kMXCellVoiceDurationLabelToBubbleSpacing-durationTextWidth, self.bubbleImageFrame.origin.y, durationTextWidth, durationTextHeight);
    } else {
        //收到的消息
        self.cellFromType = MXChatCellIncoming;
        //头像的frame
        if ([MXChatViewConfig sharedConfig].enableIncomingAvatar) {
            self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing, kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarDiameter, kMXCellAvatarDiameter);
        } else {
            self.avatarFrame = CGRectMake(0, 0, 0, 0);
        }
        //气泡的frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+self.avatarFrame.size.width+kMXCellAvatarToBubbleSpacing, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
        //语音图片的frame
        self.voiceImageFrame = CGRectMake(kMXCellVoiceImageToBubbleSpacing, self.bubbleImageFrame.size.height/2-voiceImageSize.height/2, voiceImageSize.width, voiceImageSize.height);
        //语音时长的frame
        self.durationLabelFrame = CGRectMake(self.bubbleImageFrame.origin.x+self.bubbleImageFrame.size.width+kMXCellVoiceDurationLabelToBubbleSpacing, self.bubbleImageFrame.origin.y+self.bubbleImageFrame.size.height/2-durationTextHeight/2, durationTextWidth, durationTextHeight);
        //未播放按钮的frame
        self.notPlayViewFrame = CGRectMake(self.bubbleImageFrame.origin.x + self.bubbleImageFrame.size.width + kMXCellVoiceDurationLabelToBubbleSpacing, self.bubbleImageFrame.origin.y, kMXCellVoiceNotPlayPointViewDiameter, kMXCellVoiceNotPlayPointViewDiameter);
    }
    
    // 重新计算已读状态指示器的frame
    [self calculateReadStatusIndicatorFrame];
}

- (void)updateOutgoingAvatarImage:(UIImage *)avatarImage {
    if (self.cellFromType == MXChatCellOutgoing) {
        self.avatarImage = avatarImage;
    }
}


@end
