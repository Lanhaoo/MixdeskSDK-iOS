//
//  MXWebViewBubbleCell.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/9/5.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXWebViewBubbleCell.h"
#import "MXBundleUtil.h"
#import "MXCellModelProtocol.h"
#import "MXChatViewConfig.h"
#import "MXFeedbackBtnView.h"
#import "MXImageUtil.h"
#import "MXQuickBtnView.h"
#import "MXTagListView.h"
#import "MXTextMessage.h"
#import "MXWebViewBubbleCellModel.h"
#import "UIView+MXLayout.h"
#import <SafariServices/SafariServices.h>

@interface MXWebViewBubbleCell ()

@property(nonatomic, strong) UIImageView *bubbleImageView;
@property(nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation MXWebViewBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    // 初始化头像
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.avatarImageView];
    // 初始化气泡
    self.bubbleImageView = [[UIImageView alloc] init];
    self.bubbleImageView.userInteractionEnabled = true;
    [self.contentView addSubview:self.bubbleImageView];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  for (UIView *tempView in self.contentView.subviews) {
    if ([tempView isKindOfClass:[MXTagListView class]] ||
        [tempView isKindOfClass:[MXQuickBtnView class]] ||
        [tempView isKindOfClass:[MXFeedbackBtnView class]]) {
      [tempView removeFromSuperview];
    }
  }
  [self.bubbleImageView.subviews.firstObject removeFromSuperview];
}

- (UIViewController *)topViewController {
  UIViewController *rootVC =
      [UIApplication sharedApplication].keyWindow.rootViewController;
  return [self topViewControllerWithRootViewController:rootVC];
}

- (UIViewController *)topViewControllerWithRootViewController:
    (UIViewController *)rootViewController {
  if ([rootViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController =
        (UINavigationController *)rootViewController;
    return [self
        topViewControllerWithRootViewController:navigationController
                                                    .visibleViewController];
  }

  if ([rootViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabController =
        (UITabBarController *)rootViewController;
    return [self
        topViewControllerWithRootViewController:tabController
                                                    .selectedViewController];
  }

  if (rootViewController.presentedViewController) {
    return [self
        topViewControllerWithRootViewController:rootViewController
                                                    .presentedViewController];
  }

  return rootViewController;
}

- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
  if (![model isKindOfClass:[MXWebViewBubbleCellModel class]]) {
    NSAssert(NO, @"传给MXWebViewBubbleCell的Model类型不正确");
    return;
  }
  MXWebViewBubbleCellModel *cellModel = model;

  // 刷新头像
  if (cellModel.avatarImage) {
    self.avatarImageView.image = cellModel.avatarImage;
  }
  self.avatarImageView.frame = cellModel.avatarFrame;
  if ([MXChatViewConfig sharedConfig].enableRoundAvatar) {
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius =
        cellModel.avatarFrame.size.width / 2;
  }

  // 刷新气泡
  self.bubbleImageView.image = cellModel.bubbleImage;
  self.bubbleImageView.frame = cellModel.bubbleFrame;

  CGFloat tagViewHeight = 0;

  [self.bubbleImageView addSubview:cellModel.contentWebView];
  cellModel.contentWebView.scrollView.zoomScale = 1.0;
  cellModel.contentWebView.scrollView.contentSize = CGSizeMake(0, 0);

  [cellModel.contentWebView setTappedLink:^(NSURL *url) {
    if ([url.absoluteString rangeOfString:@"://"].location == NSNotFound) {
      if ([url.absoluteString rangeOfString:@"tel:"].location != NSNotFound) {
        // 和后台预定的是 tel:182xxxxxxxxx
        NSString *path =
            [url.absoluteString stringByReplacingOccurrencesOfString:@"tel:"
                                                          withString:@"tel://"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
      } else {
        [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:
                               [NSString stringWithFormat:@"https://%@",
                                                          url.absoluteString]]];
      }
    } else {
      [[UIApplication sharedApplication] openURL:url];
    }
  }];

  if (cellModel.cacheTagListView) {
    tagViewHeight =
        cellModel.cacheTagListView.viewHeight + kMXCellBubbleToIndicatorSpacing;
    cellModel.cacheTagListView.frame =
        CGRectMake(CGRectGetMinX(self.bubbleImageView.frame),
                   CGRectGetMaxY(self.bubbleImageView.frame) +
                       kMXCellBubbleToIndicatorSpacing,
                   cellModel.cacheTagListView.bounds.size.width,
                   cellModel.cacheTagListView.bounds.size.height);
    [self.contentView addSubview:cellModel.cacheTagListView];

    NSArray *cacheTags = [[NSArray alloc] initWithArray:cellModel.cacheTags];
    __weak typeof(self) weakSelf = self;
    __weak typeof(cellModel) weakTempModel = cellModel;

    cellModel.cacheTagListView.mxTagListSelectedIndex = ^(NSInteger index) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      MXMessageBottomTagModel *model = cacheTags[index];
      switch (model.tagType) {
      case MXMessageBottomTagTypeCopy:
        [[UIPasteboard generalPasteboard] setString:model.value];
        if (strongSelf.chatCellDelegate) {
          if ([strongSelf.chatCellDelegate respondsToSelector:@selector
                                           (showToastViewInCell:toastText:)]) {
            [strongSelf.chatCellDelegate
                showToastViewInCell:strongSelf
                          toastText:[MXBundleUtil localizedStringForKey:
                                                      @"save_text_success"]];
          }
        }
        break;
      case MXMessageBottomTagTypeCall: {
        NSURL *phoneURL = [NSURL
            URLWithString:[NSString stringWithFormat:@"tel:%@", model.value]];
        if (@available(iOS 10.0, *)) {
          [[UIApplication sharedApplication] openURL:phoneURL
                                             options:@{}
                                   completionHandler:nil];
        } else {
// 兼容旧版iOS
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
          [[UIApplication sharedApplication] openURL:phoneURL];
#pragma clang diagnostic pop
        }
      } break;
      case MXMessageBottomTagTypeLink:
        if (@available(iOS 9.0, *)) {
          SFSafariViewController *safariVC = [[SFSafariViewController alloc]
              initWithURL:[NSURL URLWithString:model.value]];
          UIViewController *topVC = [self topViewController];
          [topVC presentViewController:safariVC animated:YES completion:nil];
        } else {
          [[UIApplication sharedApplication]
              openURL:[NSURL URLWithString:model.value]];
        }
        break;
      default:
        break;
      }
    };
  }

  // 处理快捷按钮
  if (cellModel.cacheQuickBtnView) {
    CGFloat quickBtnY = CGRectGetMaxY(self.bubbleImageView.frame) +
                        kMXCellBubbleToIndicatorSpacing;
    if (cellModel.cacheTagListView) {
      quickBtnY = CGRectGetMaxY(cellModel.cacheTagListView.frame) +
                  kMXCellBubbleToIndicatorSpacing;
    }

    // 设置快捷按钮位置
    [cellModel.cacheQuickBtnView
        setFrame:CGRectMake(CGRectGetMinX(self.bubbleImageView.frame),
                            quickBtnY,
                            cellModel.cacheQuickBtnView.frame.size.width,
                            cellModel.cacheQuickBtnView.frame.size.height)];

    [self.contentView addSubview:cellModel.cacheQuickBtnView];
  }

  // 处理反馈按钮
  if (cellModel.cacheFeedbackBtnView) {
    CGFloat feedbackBtnY = CGRectGetMaxY(self.bubbleImageView.frame) +
                           kMXCellBubbleToIndicatorSpacing;
    if (cellModel.cacheTagListView) {
      feedbackBtnY = CGRectGetMaxY(cellModel.cacheTagListView.frame) +
                     kMXCellBubbleToIndicatorSpacing;
    }
    if (cellModel.cacheQuickBtnView) {
      feedbackBtnY = CGRectGetMaxY(cellModel.cacheQuickBtnView.frame) +
                     kMXCellBubbleToIndicatorSpacing;
    }

    // 设置反馈按钮位置
    [cellModel.cacheFeedbackBtnView
        setFrame:CGRectMake(
                     kMXCellAvatarToHorizontalEdgeSpacing +
                         kMXCellAvatarDiameter + kMXCellAvatarToBubbleSpacing,
                     0.0, cellModel.cacheFeedbackBtnView.frame.size.width,
                     cellModel.cacheFeedbackBtnView.frame.size.height)];

    [self.contentView addSubview:cellModel.cacheFeedbackBtnView];
  }
}

@end
