//
//  MXRichTextViewModel.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXRichTextViewModel.h"
#import "MXAssetUtil.h"
#import "MXRichTextMessage.h"
#import "MXRichTextViewCell.h"
#import "MXServiceToViewInterface.h"
#import "MXWebViewBubbleCell.h"
#import "MXWebViewController.h"

@interface MXRichTextViewModel ()

@property(nonatomic, strong) MXRichTextMessage *message;

/**
 * @brief 已读状态指示器的frame
 */
@property (nonatomic, readwrite, assign) CGRect readStatusIndicatorFrame;

@end

@implementation MXRichTextViewModel

- (id)initCellModelWithMessage:(MXRichTextMessage *)message
                     cellWidth:(CGFloat)cellWidth
                      delegate:(id<MXCellModelDelegate>)delegator {
  if (self = [super init]) {
    self.message = message;
    self.readStatus = message.readStatus;
    self.summary = self.message.summary;
    self.iconPath = self.message.thumbnail;
    self.content = self.message.content;
  }
  return self;
}

// 加载 UI 需要的数据，完成后通过 UI 绑定的 block 更新 UI
- (void)load {
  if (self.modelChanges) {
    self.modelChanges(self.message.summary, self.message.thumbnail,
                      self.message.content);
  }

  __weak typeof(self) wself = self;
  [MXServiceToViewInterface
      downloadMediaWithUrlString:self.message.userAvatarPath
                        progress:nil
                      completion:^(NSData *mediaData, NSError *error) {
                        if (mediaData) {
                          __strong typeof(wself) sself = wself;
                          sself.avartarImage =
                              [UIImage imageWithData:mediaData];
                          if (sself.avatarLoaded) {
                            sself.avatarLoaded(sself.avartarImage);
                          }
                        }
                      }];

  [MXServiceToViewInterface
      downloadMediaWithUrlString:self.message.thumbnail
                        progress:nil
                      completion:^(NSData *mediaData, NSError *error) {
                        if (mediaData) {
                          __strong typeof(wself) sself = wself;
                          sself.iconImage = [UIImage imageWithData:mediaData];
                          if (sself.iconLoaded) {
                            sself.iconLoaded(sself.iconImage);
                          }
                        }
                      }];
}

- (void)openFrom:(UINavigationController *)cv {

  MXWebViewController *webViewController;

  webViewController = [MXWebViewController new];
  webViewController.contentHTML = self.content;
  webViewController.title = @"图文消息";
  [cv pushViewController:webViewController animated:YES];
}

- (CGFloat)getCellHeight {
  if (self.cellHeight) {
    return self.cellHeight();
  }
  return 80;
}

- (MXRichTextViewCell *)getCellWithReuseIdentifier:
    (NSString *)cellReuseIdentifer {
  return [[MXRichTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellReuseIdentifer];
}

//- ( MXNewRichMessageCell*)getCellWithReuseIdentifier:(NSString
//*)cellReuseIdentifer {
//    return [[MXNewRichMessageCell alloc]
//    initWithStyle:UITableViewCellStyleDefault
//    reuseIdentifier:cellReuseIdentifer];
//}

//- (MXWebViewBubbleCell*)getCellWithReuseIdentifier:(NSString
//*)cellReuseIdentifer {
//    return [[MXWebViewBubbleCell alloc]
//    initWithStyle:UITableViewCellStyleDefault
//    reuseIdentifier:cellReuseIdentifer];
//}

- (NSDate *)getCellDate {
  return self.message.date;
}

- (BOOL)isServiceRelatedCell {
  return true;
}

- (NSString *)getCellMessageId {
  return self.message.messageId;
}

- (NSString *)getMessageReadStatus {
    return self.readStatus;
}

- (NSString *)getMessageConversionId {
  return self.message.conversionId;
}

- (void)updateCellSendStatus:(MXChatMessageSendStatus)sendStatus {
  self.message.sendStatus = sendStatus;
}

- (void)updateCellMessageId:(NSString *)messageId {
  self.message.messageId = messageId;
}

- (void)updateCellReadStatus:(NSNumber *)readStatus {
    self.readStatus = readStatus;
}

- (void)updateCellConversionId:(NSString *)conversionId {
  self.message.conversionId = conversionId;
}

- (void)updateCellMessageDate:(NSDate *)messageDate {
  self.message.date = messageDate;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
  // 为 RichTextView 计算状态指示器frame
  // 由于这个Cell使用AutoLayout，我们设置一个简化的bubble frame用于计算
  CGFloat avatarSpacing = 15.0; // 头像到边缘的间距
  CGFloat avatarSize = 44.0;    // 头像尺寸
  CGFloat bubbleSpacing = 10.0; // 头像到气泡的间距
  CGFloat edgeSpacing = 15.0;   // 气泡到边缘的间距
  CGFloat verticalSpacing = 10.0; // 垂直间距
  
  CGRect bubbleFrame = CGRectMake(avatarSpacing + avatarSize + bubbleSpacing, 
                                 verticalSpacing, 
                                 cellWidth - avatarSpacing - avatarSize - bubbleSpacing - edgeSpacing, 
                                 100); // 高度由AutoLayout决定，这里设置一个默认值
  
  // 计算已读状态指示器的frame (仅对发送的消息显示)
  CGFloat statusIndicatorSize = 12.0; // 状态指示器大小
  if (self.message.fromType == MXChatMessageOutgoing) {
      // 状态指示器放在气泡左边5像素，垂直居中对齐气泡底部
      self.readStatusIndicatorFrame = CGRectMake(CGRectGetMinX(bubbleFrame) - statusIndicatorSize - 5,
                                                CGRectGetMaxY(bubbleFrame) - statusIndicatorSize,
                                                statusIndicatorSize,
                                                statusIndicatorSize);
  } else {
      // 接收的消息不显示状态指示器
      self.readStatusIndicatorFrame = CGRectZero;
  }
}

@end
