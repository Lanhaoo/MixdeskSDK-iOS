//
//  MXFeedbackBtnView.m
//  MXEcoboostSDK-test
//
//  Created on 2025-05-22.
//  Copyright © 2025 Mixdesk Inc. All rights reserved.
//

#import "MXFeedbackBtnView.h"
#import "MXBundleUtil.h"
#import "UIColor+MXHex.h"
#import "UIView+MXLayout.h"
#import "MXServiceToViewInterface.h"
#import "MXChatViewConfig.h"
#import <UIKit/UIKit.h>

// 颜色计算辅助函数
@interface UIColor (MXBrightness)

// 判断颜色是否为浅色
+ (BOOL)mx_isLightColor:(UIColor *)color;

// 根据背景色获取合适的文本颜色
+ (UIColor *)mx_textColorForBackgroundColor:(UIColor *)backgroundColor;

@end

@implementation UIColor (MXBrightness)

+ (BOOL)mx_isLightColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    // 计算亮度，与 web 端相同的计算方式
    CGFloat brightness = (r * 299 + g * 587 + b * 114) / 1000;
    
    // 亮度阈值，通常为 128/255
    return brightness > 0.5;
}

+ (UIColor *)mx_textColorForBackgroundColor:(UIColor *)backgroundColor {
    return [self mx_isLightColor:backgroundColor] ? [UIColor colorWithRed:29/255.0 green:39/255.0 blue:84/255.0 alpha:1.0] : [UIColor whiteColor];
}

@end

@interface MXFeedbackButton : UIButton

@property(nonatomic, strong) MXFeedbackButtonModel *btnModel;
@property(nonatomic, copy) NSString *convId;

@end

@implementation MXFeedbackButton

- (instancetype)initWithModel:(MXFeedbackButtonModel *)model
                       convId:(NSString *)convId {
  self = [super init];
  if (self) {
    _btnModel = model;
    _convId = convId;

    [self setupUI];
  }
  return self;
}

// 判断颜色是否为浅色
- (BOOL)isLightColor:(UIColor *)color {
  CGFloat r = 0, g = 0, b = 0, a = 0;
  [color getRed:&r green:&g blue:&b alpha:&a];
  
  // 计算亮度，与 web 端相同的计算方式
  CGFloat brightness = (r * 299 + g * 587 + b * 114) / 1000;
  
  // 亮度阈值，通常为 128/255
  return brightness > 0.5;
}

// 根据背景色获取合适的文本颜色
- (UIColor *)textColorForBackgroundColor:(UIColor *)backgroundColor {
  return [self isLightColor:backgroundColor] ? 
      [UIColor colorWithRed:29/255.0 green:39/255.0 blue:84/255.0 alpha:1.0] : 
      [UIColor whiteColor];
}

- (void)setupUI {
  self.titleLabel.font = [UIFont systemFontOfSize:12];
  self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self setTitle:self.btnModel.content forState:UIControlStateNormal];

  self.layer.cornerRadius = 4;
  self.layer.masksToBounds = YES;
  self.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);

  // 使用应用的主题色作为背景色
  UIColor *backgroundColor = nil;
  
  // 优先使用outgoingBubbleColor作为按钮背景色
  if ([MXChatViewConfig sharedConfig].chatViewStyle.outgoingBubbleColor) {
    backgroundColor = [MXChatViewConfig sharedConfig].chatViewStyle.outgoingBubbleColor;
  } else if ([UIColor respondsToSelector:@selector(systemBlueColor)]) {
    // 如果没有设置，则使用系统蓝色
    backgroundColor = [UIColor systemBlueColor];
  } else {
    // 兼容旧版本 iOS
    backgroundColor = [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0];
  }
  
  self.backgroundColor = backgroundColor;
  
  // 根据背景色自动计算文本颜色
  UIColor *textColor = [self textColorForBackgroundColor:backgroundColor];
  [self setTitleColor:textColor forState:UIControlStateNormal];
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize titleSize = [self.titleLabel.text
      sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
  return CGSizeMake(titleSize.width + 20, 28); // 左右各10pt的padding，高度28
}

@end

@interface MXFeedbackBtnView ()

@property(nonatomic, strong) NSArray *feedbackBtns;
@property(nonatomic, strong) NSMutableArray *buttonViews;
@property(nonatomic, assign) CGFloat maxWidth;
@property(nonatomic, copy) NSString *convId;

@end

@implementation MXFeedbackBtnView

- (instancetype)initWithFeedbackBtns:(NSArray *)feedbackBtns
                            maxWidth:(CGFloat)maxWidth
                              convId:(NSString *)convId {
  self = [super init];
  if (self) {
    _feedbackBtns = feedbackBtns;
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
  CGFloat buttonHeight = 28; // 设置比快捷按钮稍高一些
  CGFloat buttonSpacing = 10;

  // 确保最大宽度有效
  if (self.maxWidth <= 0) {
    self.maxWidth = 280; // 设置一个默认最大宽度
  }

  for (MXFeedbackButtonModel *model in self.feedbackBtns) {
    MXFeedbackButton *button = [[MXFeedbackButton alloc] initWithModel:model
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

- (CGFloat)getViewHeight {
  return CGRectGetHeight(self.frame);
}

- (void)buttonClicked:(MXFeedbackButton *)button {
  MXFeedbackButtonModel *model = button.btnModel;

  // 处理点击回调
  if (self.mxFeedbackBtnClickedWithModel) {
    self.mxFeedbackBtnClickedWithModel(model);
  }
  
  // 发送反馈内容
  [self sendFeedbackWithModel:model];
}

/**
 * 发送反馈的封装方法
 * @param model 反馈按钮模型对象
 */
- (void)sendFeedbackWithModel:(MXFeedbackButtonModel *)model {
  // 获取当前控制器
  UIViewController *topVC = [self topViewController];

  // 确保反馈内容不为空
  NSString *messageContent = model.content;
  if (!messageContent || messageContent.length == 0) {
    return;
  }

  NSLog(@"发送反馈内容: %@", messageContent);

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
      }
    }
  }
}

// 获取当前顶层视图控制器
- (UIViewController *)topViewController {
  UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
  
  while (topController.presentedViewController) {
    topController = topController.presentedViewController;
  }
  
  if ([topController isKindOfClass:[UINavigationController class]]) {
    topController = [(UINavigationController *)topController topViewController];
  }
  
  return topController;
}

@end
