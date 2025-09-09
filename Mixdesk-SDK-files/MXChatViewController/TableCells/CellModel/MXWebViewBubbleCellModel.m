//
//  MXMXWebViewBubbleCellModel.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright 2016年 Mixdesk. All rights reserved.
//

#import "MXWebViewBubbleCellModel.h"
#import "MXChatViewConfig.h"
#import "MXFeedbackBtnView.h"
#import "MXHybridMessage.h"
#import "MXImageUtil.h"
#import "MXQuickBtnView.h"
#import "MXRichTextMessage.h"
#import "MXServiceToViewInterface.h"
#import "MXWebViewBubbleCell.h"

@interface MXWebViewBubbleCellModel ()

/**
 * @brief cell的高度
 */
@property(nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 标签签的tagList
 */
@property(nonatomic, strong) MXTagListView *cacheTagListView;
@property(nonatomic, strong) MXQuickBtnView *cacheQuickBtnView;
@property(nonatomic, strong) MXFeedbackBtnView *cacheFeedbackBtnView;
/**
 * @brief 标签的数据源
 */
@property(nonatomic, readwrite, strong) NSArray *cacheTags;

/**
 * @brief 消息背景框的frame
 */
@property(nonatomic, readwrite, assign) CGRect bubbleFrame;

/**
 * @brief 聊天气泡的image
 */
@property(nonatomic, readwrite, copy) UIImage *bubbleImage;

/**
 * @brief 发送者的头像的图片
 */
@property(nonatomic, readwrite, copy) UIImage *avatarImage;

/**
 * @brief 发送者的头像frame
 */
@property(nonatomic, readwrite, assign) CGRect avatarFrame;

@property(nonatomic, readwrite, strong) MXEmbededWebView *contentWebView;

/**
 * @brief 该cellModel的委托对象
 */
@property(nonatomic, weak) id<MXCellModelDelegate> delegate;

@property(nonatomic, strong) MXRichTextMessage *message;

@property(nonatomic, assign) CGFloat webCacheHeight;

@end

@implementation MXWebViewBubbleCellModel

- (id)initCellModelWithMessage:(MXRichTextMessage *)message
                     cellWidth:(CGFloat)cellWidth
                      delegate:(id<MXCellModelDelegate>)delegator {
  if (self = [super init]) {
    self.message = message;
    self.delegate = delegator;

    if (message.userAvatarImage) {
      self.avatarImage = message.userAvatarImage;
    } else if (message.userAvatarPath.length > 0) {
      // 这里使用Mixdesk接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
      __weak typeof(self) weakSelf = self;
#ifdef INCLUDE_MIXDESK_SDK
      [MXServiceToViewInterface
          downloadMediaWithUrlString:message.userAvatarPath
          progress:^(float progress) {
          }
          completion:^(NSData *mediaData, NSError *error) {
            if (mediaData && !error) {
              weakSelf.avatarImage = [UIImage imageWithData:mediaData];
            } else {
              weakSelf.avatarImage = message.fromType == MXChatMessageIncoming
                                         ? [MXChatViewConfig sharedConfig]
                                               .incomingDefaultAvatarImage
                                         : [MXChatViewConfig sharedConfig]
                                               .outgoingDefaultAvatarImage;
            }
            if (weakSelf.delegate) {
              if ([weakSelf.delegate respondsToSelector:@selector
                                     (didUpdateCellDataWithMessageId:)]) {
                // 通知ViewController去刷新tableView
                [weakSelf.delegate
                    didUpdateCellDataWithMessageId:weakSelf.message.messageId];
              }
            }
          }];
#else
      __block UIImageView *tempImageView = [UIImageView new];
      [tempImageView
          sd_setImageWithURL:[NSURL URLWithString:message.userAvatarPath]
            placeholderImage:nil
                     options:SDWebImageProgressiveDownload
                   completed:^(UIImage *image, NSError *error,
                               SDImageCacheType cacheType, NSURL *imageURL) {
                     weakSelf.avatarImage = tempImageView.image.copy;
                     if (weakSelf.delegate) {
                       if ([weakSelf.delegate
                               respondsToSelector:@selector
                               (didUpdateCellDataWithMessageId:)]) {
                         // 通知ViewController去刷新tableView
                         [weakSelf.delegate
                             didUpdateCellDataWithMessageId:weakSelf.message
                                                                .messageId];
                       }
                     }
                   }];
#endif
    } else {
      self.avatarImage =
          [MXChatViewConfig sharedConfig].incomingDefaultAvatarImage;
      if (message.fromType == MXChatMessageOutgoing) {
        self.avatarImage =
            [MXChatViewConfig sharedConfig].outgoingDefaultAvatarImage;
      }
    }

    if (message.tags) {
      CGFloat maxWidth = cellWidth - kMXCellAvatarToHorizontalEdgeSpacing -
                         kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing -
                         kMXCellBubbleToTextHorizontalLargerSpacing -
                         kMXCellBubbleToTextHorizontalSmallerSpacing -
                         kMXCellBubbleMaxWidthToEdgeSpacing;
      NSMutableArray *titleArr = [NSMutableArray array];
      for (MXMessageBottomTagModel *model in message.tags) {
        [titleArr addObject:model.name];
      }
      self.cacheTagListView = [[MXTagListView alloc]
          initWithTitleArray:titleArr
                 andMaxWidth:maxWidth
          tagBackgroundColor:[UIColor colorWithWhite:1 alpha:0]
               tagTitleColor:[UIColor grayColor]
                 tagFontSize:12.0
                  needBorder:YES];
      self.cacheTags = message.tags;
    }

    if (message.quickBtns && message.quickBtns.count > 0) {
      // 计算快捷按钮可用的最大宽度，适当减小预留空间
      CGFloat maxAvailableWidth =
          cellWidth - kMXCellAvatarToHorizontalEdgeSpacing -
          kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing - 10;

      // 确保宽度不会超出屏幕
      if (maxAvailableWidth > [UIScreen mainScreen].bounds.size.width - 40) {
        maxAvailableWidth = [UIScreen mainScreen].bounds.size.width - 40;
      }

      self.cacheQuickBtnView =
          [[MXQuickBtnView alloc] initWithQuickBtns:message.quickBtns
                                           maxWidth:maxAvailableWidth
                                             convId:message.conversionId];
      __weak typeof(self) weakSelf = self;
      self.cacheQuickBtnView.mxQuickBtnClickedWithModel =
          ^(MXMessageBottomQuickBtnModel *model) {
            [MXServiceToViewInterface clickQuickBtn:model.func_id
                                       quick_btn_id:@(model.id)
                                               func:@(model.func)];
          };
    }

    if (message.feedbackBtns && message.feedbackBtns.count > 0) {
      // 计算反馈按钮可用的最大宽度，适当减小预留空间
      CGFloat maxAvailableWidth =
          cellWidth - kMXCellAvatarToHorizontalEdgeSpacing -
          kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing - 10;

      // 确保宽度不会超出屏幕
      if (maxAvailableWidth > [UIScreen mainScreen].bounds.size.width - 40) {
        maxAvailableWidth = [UIScreen mainScreen].bounds.size.width - 40;
      }

      self.cacheFeedbackBtnView =
          [[MXFeedbackBtnView alloc] initWithFeedbackBtns:message.feedbackBtns
                                                 maxWidth:maxAvailableWidth
                                                   convId:message.conversionId];
      __weak typeof(self) weakSelf = self;
      self.cacheFeedbackBtnView.mxFeedbackBtnClickedWithModel =
          ^(MXFeedbackButtonModel *model) {
            // 可以在这里添加反馈按钮点击的额外处理逻辑
            NSLog(@"反馈按钮被点击: %@", model.content);
          };
    }
    [self configUIWithCellWidth:cellWidth];
    __weak typeof(self) weakSelf = self;
    [self.contentWebView
              loadHTML:message.content
        WithCompletion:^(CGFloat height) {
          if (weakSelf.webCacheHeight != height) {
            weakSelf.webCacheHeight = height;
            if (weakSelf.delegate) {
              if ([weakSelf.delegate respondsToSelector:@selector
                                     (didUpdateCellDataWithMessageId:)]) {
                // 通知ViewController去刷新tableView
                [weakSelf configUIWithCellWidth:cellWidth];
                [weakSelf.delegate
                    didUpdateCellDataWithMessageId:weakSelf.message.messageId];
              }
            }
          }
        }];
  }
  return self;
}

#pragma mark - Public

#pragma mark - Private

- (void)configUIWithCellWidth:(CGFloat)cellWidth {
  // webView的宽度
  CGFloat webViewWidth = cellWidth - kMXCellAvatarToHorizontalEdgeSpacing -
                         kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing -
                         kMXCellBubbleToTextHorizontalLargerSpacing -
                         kMXCellBubbleToTextHorizontalSmallerSpacing -
                         kMXCellBubbleMaxWidthToEdgeSpacing;
  // webView的高度
  CGFloat webViewHeight = self.webCacheHeight > 0 ? self.webCacheHeight : 50;

  // 气泡高度
  CGFloat bubbleHeight = webViewHeight;
  // 气泡宽度
  CGFloat bubbleWidth = webViewWidth +
                        kMXCellBubbleToTextHorizontalLargerSpacing +
                        kMXCellBubbleToTextHorizontalSmallerSpacing;

  // 根据消息的来源，进行处理
  UIImage *bubbleImage = [MXChatViewConfig sharedConfig].incomingBubbleImage;
  if ([MXChatViewConfig sharedConfig].incomingBubbleColor) {
    bubbleImage =
        [MXImageUtil convertImageColorWithImage:bubbleImage
                                        toColor:[MXChatViewConfig sharedConfig]
                                                    .incomingBubbleColor];
  }

  // 收到的消息
  // 头像的frame
  if ([MXChatViewConfig sharedConfig].enableIncomingAvatar &&
          ![self.message isKindOfClass:[MXHybridMessage class]] ||
      ([self.message isKindOfClass:[MXHybridMessage class]] &&
       !((MXHybridMessage *)self.message).hideAvatar)) {
    self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing,
                                  kMXCellAvatarToVerticalEdgeSpacing,
                                  kMXCellAvatarDiameter, kMXCellAvatarDiameter);
  } else {
    self.avatarFrame = CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing,
                                  kMXCellAvatarToVerticalEdgeSpacing, 0, 0);
  }

  // 气泡的frame
  if ([self.message isKindOfClass:[MXHybridMessage class]] &&
      ((MXHybridMessage *)self.message).hideAvatar) {
    // 当hideAvatar为true时，气泡直接放在左边
    self.bubbleFrame =
        CGRectMake(kMXCellAvatarToHorizontalEdgeSpacing,
                   self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
    // 当hideAvatar为true时，不设置气泡图片
    self.bubbleImage = nil;
  } else {
    // 普通情况，考虑头像位置
    self.bubbleFrame =
        CGRectMake(self.avatarFrame.origin.x + self.avatarFrame.size.width +
                       kMXCellAvatarToBubbleSpacing,
                   self.avatarFrame.origin.y, bubbleWidth, bubbleHeight);
    // 普通情况下设置气泡图片
    self.bubbleImage =
        [bubbleImage resizableImageWithCapInsets:[MXChatViewConfig sharedConfig]
                                                     .bubbleImageStretchInsets];
  }

  self.contentWebView.frame =
      CGRectMake(kMXCellBubbleToTextHorizontalLargerSpacing, 0, webViewWidth,
                 webViewHeight);

  // 计算cell的高度
  CGFloat tagHeight = 0;
  if (self.cacheTagListView) {
    tagHeight = self.cacheTagListView.frame.size.height +
                kMXCellBubbleToIndicatorSpacing;
  }

  CGFloat quickBtnHeight = 0;
  if (self.cacheQuickBtnView) {
    quickBtnHeight = [self.cacheQuickBtnView getViewHeight] +
                     kMXCellBubbleToIndicatorSpacing;
  }

  CGFloat feedbackBtnHeight = 0;
  if (self.cacheFeedbackBtnView) {
    feedbackBtnHeight = [self.cacheFeedbackBtnView getViewHeight] /* +kMXCellBubbleToIndicatorSpacing */;
  }

  self.cellHeight = self.bubbleFrame.origin.y + self.bubbleFrame.size.height +
                    kMXCellAvatarToVerticalEdgeSpacing + tagHeight +
                    quickBtnHeight + feedbackBtnHeight;
}

#pragma mark - MXCellModelProtocol

- (CGFloat)getCellHeight {
  return self.cellHeight > 0 ? self.cellHeight : 0;
}

- (MXWebViewBubbleCell *)getCellWithReuseIdentifier:
    (NSString *)cellReuseIdentifer {
  return [[MXWebViewBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:cellReuseIdentifer];
}

- (NSDate *)getCellDate {
  return self.message.date;
}

- (BOOL)isServiceRelatedCell {
  return true;
}

- (NSString *)getMessageReadStatus {
  return @"";
}

- (NSString *)getCellMessageId {
  return self.message.messageId;
}

- (NSString *)getMessageConversionId {
  return self.message.conversionId;
}

- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus {
  self.message.sendStatus = sendStatus;
}

- (void)updateCellReadStatus:(NSNumber *)readStatus {
  self.message.readStatus = readStatus;
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
  CGFloat maxWidth = cellWidth - kMXCellAvatarToHorizontalEdgeSpacing -
                     kMXCellAvatarDiameter - kMXCellAvatarToBubbleSpacing -
                     kMXCellBubbleToTextHorizontalLargerSpacing -
                     kMXCellBubbleToTextHorizontalSmallerSpacing -
                     kMXCellBubbleMaxWidthToEdgeSpacing;
  [self.cacheTagListView updateLayoutWithMaxWidth:maxWidth];
  if (self.cacheQuickBtnView) {
    [self.cacheQuickBtnView updateLayoutWithMaxWidth:maxWidth];
  }
  if (self.cacheFeedbackBtnView) {
    [self.cacheFeedbackBtnView updateLayoutWithMaxWidth:maxWidth];
  }
  [self configUIWithCellWidth:cellWidth];
}

#pragma mark - 懒加载

- (MXEmbededWebView *)contentWebView {
  if (!_contentWebView) {
    _contentWebView = [MXEmbededWebView new];
    _contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  }
  return _contentWebView;
}

@end
