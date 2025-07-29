//
//  MXQuickBtnView.m
//  MXEcoboostSDK-test
//
//  Created on 2025-05-21.
//  Copyright © 2025 Mixdesk Inc. All rights reserved.
//

#import "MXQuickBtnView.h"
#import "MXBundleUtil.h"
#import "MXServiceToViewInterface.h"
#import "UIColor+MXHex.h"
#import "UIView+MXLayout.h"
#import <SafariServices/SafariServices.h>

@interface MXQuickButton : UIButton

@property(nonatomic, strong) MXMessageBottomQuickBtnModel *btnModel;
@property(nonatomic, copy) NSString *convId;

@end

@implementation MXQuickButton

- (instancetype)initWithModel:(MXMessageBottomQuickBtnModel *)model
                       convId:(NSString *)convId {
  self = [super init];
  if (self) {
    _btnModel = model;
    _convId = convId;

    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.titleLabel.font = [UIFont systemFontOfSize:12];
  self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self setTitle:self.btnModel.btn_text forState:UIControlStateNormal];

  self.layer.cornerRadius = 4;
  self.layer.masksToBounds = YES;
  self.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);

  [self applyStyle];
}

- (void)applyStyle {
  NSDictionary *styleDict;

  if ([self.btnModel.style isKindOfClass:[NSDictionary class]]) {
    styleDict = (NSDictionary *)self.btnModel.style;
  } else if ([self.btnModel.style isKindOfClass:[NSString class]]) {
    NSData *jsonData = [(NSString *)self.btnModel.style
        dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
      styleDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:0
                                                    error:nil];
    }
  }

  if (styleDict) {
    NSString *colorStr = styleDict[@"color"];
    NSNumber *bgType = styleDict[@"bg"];

    UIColor *color = colorStr ? [UIColor mx_colorWithHexString:colorStr]
                              : [UIColor blackColor];

    if (bgType && [bgType intValue] == 1) {
      // 背景色填充模式
      self.backgroundColor = color;
      [self setTitleColor:[self getTextColorForBackgroundColor:color]
                 forState:UIControlStateNormal];
    } else {
      // 描边模式
      self.backgroundColor = [UIColor clearColor];
      [self setTitleColor:color forState:UIControlStateNormal];
      self.layer.borderColor = color.CGColor;
      self.layer.borderWidth = 1.0;
    }
  } else {
    // 默认样式
    self.backgroundColor = [UIColor colorWithRed:0.9
                                           green:0.9
                                            blue:0.9
                                           alpha:1.0];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  }
}

- (UIColor *)getTextColorForBackgroundColor:(UIColor *)backgroundColor {
  CGFloat red, green, blue, alpha;
  [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];

  // 计算亮度
  CGFloat brightness = (red * 299 + green * 587 + blue * 114) / 1000;

  // 如果亮度小于0.5，则文本为白色，否则为黑色
  return brightness < 0.5 ? [UIColor whiteColor] : [UIColor blackColor];
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize titleSize = [self.titleLabel.text
      sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
  return CGSizeMake(titleSize.width + 12, 24); // 左右各6pt的padding
}

@end

// 图片弹窗视图
@interface MXImagePopoverView : UIView

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIView *backgroundView;

@end

@implementation MXImagePopoverView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.backgroundView = [[UIView alloc] init];
  self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
  self.backgroundView.frame = self.bounds;
  [self addSubview:self.backgroundView];

  self.imageView = [[UIImageView alloc] init];
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageView.frame = CGRectMake(0, 0, 180, 180);
  self.imageView.center = self.center;
  [self addSubview:self.imageView];

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(dismiss)];
  [self addGestureRecognizer:tap];
}

- (void)dismiss {
  [UIView animateWithDuration:0.3
      animations:^{
        self.alpha = 0;
      }
      completion:^(BOOL finished) {
        [self removeFromSuperview];
      }];
}

- (void)loadImageWithURL:(NSString *)url {
  // 这里应该使用适当的图片加载库，如SDWebImage
  // 简化起见，这里使用简单的方式加载
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
          self.imageView.image = image;
        });
      });
}

@end

@interface MXQuickBtnView ()

@property(nonatomic, strong) NSArray *quickBtns;
@property(nonatomic, strong) NSMutableArray *buttonViews;
@property(nonatomic, assign) CGFloat maxWidth;
@property(nonatomic, copy) NSString *convId;
@property(nonatomic, strong) MXImagePopoverView *imagePopoverView;
@property(nonatomic, strong) MXQuickButton *activeButton;

@end

@implementation MXQuickBtnView

- (instancetype)initWithQuickBtns:(NSArray *)quickBtns
                         maxWidth:(CGFloat)maxWidth
                           convId:(NSString *)convId {
  self = [super init];
  if (self) {
    _quickBtns = quickBtns;
    _maxWidth = maxWidth;
    _convId = convId;
    _buttonViews = [NSMutableArray array];

    [self setupButtons];
  }
  return self;
}

- (void)setupButtons {
  // 先移除之前的按钮
  for (UIView *subview in self.subviews) {
    [subview removeFromSuperview];
  }
  [self.buttonViews removeAllObjects];

  // 重新添加按钮
  CGFloat currentX = 0;
  CGFloat currentY = 0;
  CGFloat buttonHeight = 24;
  CGFloat buttonSpacing = 8;

  // 确保最大宽度有效
  if (self.maxWidth <= 0) {
    self.maxWidth = 280; // 设置一个默认最大宽度
  }

  for (MXMessageBottomQuickBtnModel *model in self.quickBtns) {
    MXQuickButton *button = [[MXQuickButton alloc] initWithModel:model
                                                          convId:self.convId];
    [button addTarget:self
                  action:@selector(buttonClicked:)
        forControlEvents:UIControlEventTouchUpInside];

    // 计算按钮宽度
    [button sizeToFit];
    CGFloat buttonWidth = button.frame.size.width;

    // 确保按钮宽度不超过最大宽度
    if (buttonWidth > self.maxWidth) {
      buttonWidth = self.maxWidth;
    }

    // 如果当前行放不下这个按钮，换行
    if (currentX + buttonWidth > self.maxWidth) {
      currentX = 0;
      currentY += buttonHeight + buttonSpacing;
    }

    button.frame = CGRectMake(currentX, currentY, buttonWidth, buttonHeight);
    [self addSubview:button];
    [self.buttonViews addObject:button];

    // 更新下一个按钮的位置
    currentX += buttonWidth + buttonSpacing;
  }

  // 设置视图的高度
  CGFloat totalHeight = currentY + buttonHeight;
  if (totalHeight <= 0) {
    totalHeight = buttonHeight; // 确保至少有一行的高度
  }
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          self.maxWidth, totalHeight);
}

- (void)updateLayoutWithMaxWidth:(CGFloat)maxWidth {
  self.maxWidth = maxWidth;
  [self setupButtons];
}

- (void)buttonClicked:(MXQuickButton *)button {
  MXMessageBottomQuickBtnModel *model = button.btnModel;

  // 处理点击回调
  // if (self.mxQuickBtnClickedWithModel) {
  //   self.mxQuickBtnClickedWithModel(model);
  // }

  switch (model.btn_type) {
  case 1: // 复制内容
    [self copyText:model.content];
    [self showToastWithMessage:[MXBundleUtil
                                   localizedStringForKey:@"save_text_success"]];
    break;
  case 2: // 拨打电话
  {
    NSURL *phoneURL = [NSURL
        URLWithString:[NSString stringWithFormat:@"tel:%@", model.content]];
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
  case 3: // 跳转链接
    if (@available(iOS 9.0, *)) {
      SFSafariViewController *safariVC = [[SFSafariViewController alloc]
          initWithURL:[NSURL URLWithString:model.content]];
      UIViewController *topVC = [self topViewController];
      [topVC presentViewController:safariVC animated:YES completion:nil];
    } else {
      [[UIApplication sharedApplication]
          openURL:[NSURL URLWithString:model.content]];
    }
    break;
  case 4: // 发送消息
  {
    // 调用发送消息方法
    [self sendMessageWithModel:model];
  } break;
  case 5: // 图片浮层
    [self showImagePopover:model.content fromButton:button];
    break;
  case 6: // 自助问答
    // 调用发送消息方法
    [self sendMessageWithModel:model];
    break;
  }

  // 延迟500ms
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)),
      dispatch_get_main_queue(), ^{
        // 直接调用MXServiceToViewInterface的方法
        [MXServiceToViewInterface clickQuickBtn:model.func_id
                                   quick_btn_id:model.id
                                           func:model.func];
      });
}

- (void)copyText:(NSString *)text {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.string = text;
}

/**
 * 发送消息的封装方法
 * @param model 消息模型对象
 */
- (void)sendMessageWithModel:(MXMessageBottomQuickBtnModel *)model {
  // 获取当前控制器
  UIViewController *topVC = [self topViewController];

  // 确保消息内容不为空
  NSString *messageContent = model.btn_text;

  NSLog(@"发送消息内容: %@", messageContent);

  // 判断当前控制器类型并调用相应方法
  if ([topVC isKindOfClass:NSClassFromString(@"MXChatViewController")]) {
    // 如果当前是聊天页面，使用其chatViewService发送消息
    id chatViewService = [topVC valueForKey:@"chatViewService"];
    if (chatViewService) {
      SEL sendTextSelector =
          NSSelectorFromString(@"sendTextMessageWithContent:");
      if ([chatViewService respondsToSelector:sendTextSelector]) {
        // 在主线程执行发送消息
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [chatViewService performSelector:sendTextSelector
                                withObject:messageContent];
#pragma clang diagnostic pop
        });
        return; // 已调用发送方法，返回
      }
    }
  }

  // 如果上面的方法失败，尝试使用MXManager发送
  Class managerClass = NSClassFromString(@"MXManager");
  if (managerClass) {
    SEL sendMessageSelector =
        NSSelectorFromString(@"sendTextMessageWithContent:completion:");
    if ([managerClass respondsToSelector:sendMessageSelector]) {
      dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [managerClass performSelector:sendMessageSelector
                           withObject:messageContent
                           withObject:nil];
#pragma clang diagnostic pop
      });
    }
  }

  // 显示发送成功提示
  // NSString *successMessage = [MXBundleUtil
  // localizedStringForKey:@"message_send_success"]; if (!successMessage ||
  // successMessage.length == 0) {
  //     successMessage = @"消息已发送";
  // }
  // [self showToastWithMessage:successMessage];
}

- (void)showToastWithMessage:(NSString *)message {
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  UIView *toastView = [[UIView alloc] init];
  toastView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
  toastView.layer.cornerRadius = 5;

  UILabel *textLabel = [[UILabel alloc] init];
  textLabel.text = message;
  textLabel.textColor = [UIColor whiteColor];
  textLabel.font = [UIFont systemFontOfSize:14];
  textLabel.textAlignment = NSTextAlignmentCenter;
  [toastView addSubview:textLabel];
  [window addSubview:toastView];

  [textLabel sizeToFit];
  textLabel.frame = CGRectMake(10, 10, textLabel.frame.size.width,
                               textLabel.frame.size.height);
  toastView.frame = CGRectMake(
      (window.frame.size.width - textLabel.frame.size.width - 20) / 2,
      window.frame.size.height - 100, textLabel.frame.size.width + 20,
      textLabel.frame.size.height + 20);

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [UIView animateWithDuration:0.3
                       animations:^{
                         toastView.alpha = 0;
                       }
                       completion:^(BOOL finished) {
                         [toastView removeFromSuperview];
                       }];
                 });
}

- (void)showImagePopover:(NSString *)imageUrl
              fromButton:(MXQuickButton *)button {
  // 如果已经有活跃的图片弹窗，先隐藏
  if (self.imagePopoverView) {
    [self.imagePopoverView removeFromSuperview];
    self.imagePopoverView = nil;
  }

  // 如果点击的是已经活跃的按钮，就只是隐藏弹窗
  if (button == self.activeButton) {
    self.activeButton = nil;
    return;
  }

  // 创建新的弹窗
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  self.imagePopoverView =
      [[MXImagePopoverView alloc] initWithFrame:window.bounds];
  [self.imagePopoverView loadImageWithURL:imageUrl];
  [window addSubview:self.imagePopoverView];

  // 记录当前活跃的按钮
  self.activeButton = button;
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

- (CGFloat)getViewHeight {
  return self.frame.size.height;
}

@end
