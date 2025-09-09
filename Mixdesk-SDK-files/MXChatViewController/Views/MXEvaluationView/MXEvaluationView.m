//
//  MXEvaluationView.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 16/1/19.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXEvaluationView.h"
#import "MIXDESK_CustomIOSAlertView.h"
#import "MXAssetUtil.h"
#import "MXBundleUtil.h"
#import "MXChatDeviceUtil.h"
#import "MXChatViewConfig.h"
#import "MXEvaluationCell.h"
#import "MXNamespacedDependencies.h"
#import "MXServiceToViewInterface.h"
#import "MXToast.h"
#import "UIColor+MXHex.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static CGFloat const kMXEvaluationVerticalSpacing = 16.0;   // 垂直间距
static CGFloat const kMXEvaluationHorizontalSpacing = 16.0; // 水平间距
static CGFloat const kMXEvaluationElementSpacing = 16.0; // 元素之间的间距
static CGFloat const kMXEvaluationSectionSpacing = 16.0; // 区块之间的间距

@class CustomIOSAlertView;

@interface MXEvaluationView () <CustomIOSAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation MXEvaluationView {
  CustomIOSAlertView *evaluationAlertView;
  NSInteger selectedEmojiIndex;  // 选中的表情索引 (0-4)
  NSInteger selectedNumberIndex; // 选中的数字索引 (0-3)
  NSInteger selectedSolvedStatus; // 选中的解决状态 1-已解决 0-未解决 -1-未选择
  UITextField *commentTextField;
  NSMutableArray *emojiImageViews;
  NSMutableArray *numberButtons;
  UIButton *solvedButton;           // 问题已解决按钮
  UIButton *unsolvedButton;         // 问题未解决按钮
  NSInteger evaluationType;         // 评价的等级
  MXEvaluationConfig *levels;       // 评价的配置列表
  id levelNameLabel;                // 显示表情对应的评价名称
  NSArray<MXEvaluationTag *> *tags; // 评价的标签列表
  UIView *tagsContainerView;        // 标签容器视图
  NSMutableArray *tagViews;         // 标签视图数组
  NSMutableArray *selectedTagIds;   // 当前选中的标签 ID 数组
  NSMutableDictionary *tagViewsMap; // 标签 ID 到视图的映射关系

  NSString *evaluationProblemFeedback;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self initCustomAlertView];
    selectedEmojiIndex = -1;
    selectedNumberIndex = -1;
    selectedSolvedStatus = -1; // 初始状态未选择
    emojiImageViews = [NSMutableArray array];
    numberButtons = [NSMutableArray array];
    tagViews = [NSMutableArray array];
    selectedTagIds = [NSMutableArray array]; // 初始化选中标签 ID 数组
    tagViewsMap = [NSMutableDictionary dictionary]; // 初始化标签映射关系
    // evaluationType = 3;                             // 评价的等级
    levels = nil;
    tags = nil;
  }
  return self;
}

- (void)initCustomAlertView {
  evaluationAlertView = [[CustomIOSAlertView alloc] init];
  [evaluationAlertView setContainerView:[self getCustomAlertView]];
  [evaluationAlertView
      setButtonTitles:
          [NSMutableArray
              arrayWithObjects:[MXBundleUtil
                                   localizedStringForKey:@"alert_view_cancel"],
                               [MXBundleUtil
                                   localizedStringForKey:@"alert_view_send"],
                               nil]];
  [evaluationAlertView setDelegate:self];
  [evaluationAlertView setUseMotionEffects:true];
}

- (UIView *)getCustomAlertView {
  CGRect deviceFrame = [MXChatDeviceUtil getDeviceScreenRect];
  CGFloat originX = ceil(deviceFrame.size.width / 8);
  
  // 初始高度设置为较小值，后面会根据内容动态调整
  CGFloat initialHeight = 200;
  CGFloat viewWidth = deviceFrame.size.width - originX * 2;

  // 创建主容器（始终使用 ScrollView）
  UIScrollView *scrollView = [[UIScrollView alloc] init];
  scrollView.frame = CGRectMake(0, 0, viewWidth, initialHeight);
  scrollView.backgroundColor = [UIColor whiteColor];
  scrollView.layer.cornerRadius = 8.0;
  scrollView.clipsToBounds = YES;
  scrollView.showsVerticalScrollIndicator = YES;
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.bounces = NO;
  scrollView.alwaysBounceVertical = NO;
  
  // 保存 scrollView 引用
  self.scrollView = scrollView;
  
  // 创建内容容器视图
  UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, initialHeight)];
  contentView.backgroundColor = [UIColor whiteColor];
  [scrollView addSubview:contentView];
  
  // 保存 contentView 引用
  self.contentView = contentView;

  // alertView 标题 - 智能计算文本布局
  NSString *titleText = [MXBundleUtil localizedStringForKey:@"mx_evaluation_title"];
  
  // 创建UILabel
  UILabel *alertViewTitle = [[UILabel alloc] init];
  alertViewTitle.text = titleText;
  alertViewTitle.textColor = [UIColor colorWithWhite:0.22 alpha:1];
  alertViewTitle.textAlignment = NSTextAlignmentCenter;
  alertViewTitle.font = [UIFont systemFontOfSize:17.0];
  
  // 重要设置：允许多行并设置换行模式
  alertViewTitle.numberOfLines = 0; // 无限行数
  alertViewTitle.lineBreakMode = NSLineBreakByWordWrapping; // 按词换行
  
  // 计算可用宽度 - 留出足够的左右边距
  CGFloat availableWidth = contentView.frame.size.width - 40; // 左右20点，右边20点
  
  // 使用attributedText获得更好的换行效果
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  
  NSAttributedString *attributedText = [[NSAttributedString alloc] 
      initWithString:titleText
      attributes:@{
          NSFontAttributeName: alertViewTitle.font,
          NSForegroundColorAttributeName: alertViewTitle.textColor,
          NSParagraphStyleAttributeName: paragraphStyle
      }];
  
  alertViewTitle.attributedText = attributedText;
  
  // 使用attributedText计算高度，使用完整可用宽度确保文字完全显示
  CGSize maxSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
  CGRect boundingRect = [attributedText boundingRectWithSize:maxSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   context:nil];
  
  // 设置frame - 使用完整可用宽度确保文字完全显示
  alertViewTitle.frame = CGRectMake(20, kMXEvaluationVerticalSpacing,
                                  availableWidth,
                                  ceil(boundingRect.size.height) + 10);
  
  // 居中标题
  alertViewTitle.center = CGPointMake(contentView.frame.size.width / 2, 
                                    alertViewTitle.center.y);

  [contentView addSubview:alertViewTitle];

  [MXServiceToViewInterface
      getEnterpriseConfigInfoWithCache:YES
                              complete:^(MXEnterprise *enterprise,
                                         NSError *error) {
                                if (enterprise.configInfo.evaluationPromtText
                                        .length > 0) {
                                  // 获取新的文本
                                  NSString *newTitleText = enterprise.configInfo.evaluationPromtText;
                                  
                                  // 创建新的NSAttributedString，保持换行样式
                                  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                                  paragraphStyle.alignment = NSTextAlignmentCenter;
                                  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                                  
                                  NSAttributedString *newAttributedText = [[NSAttributedString alloc] 
                                      initWithString:newTitleText
                                      attributes:@{
                                          NSFontAttributeName: alertViewTitle.font,
                                          NSForegroundColorAttributeName: alertViewTitle.textColor,
                                          NSParagraphStyleAttributeName: paragraphStyle
                                      }];
                                  
                                  // 设置新的attributedText
                                  alertViewTitle.attributedText = newAttributedText;
                                  
                                  // 重新计算高度
                                  CGSize maxSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
                                  CGRect boundingRect = [newAttributedText boundingRectWithSize:maxSize
                                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                   context:nil];
                                  
                                  // 更新frame - 确保使用完整可用宽度
                                  CGRect frame = alertViewTitle.frame;
                                  frame.size.width = availableWidth;
                                  frame.size.height = ceil(boundingRect.size.height) + 10;
                                  alertViewTitle.frame = frame;
                                  
                                  // 保持水平居中
                                  alertViewTitle.center = CGPointMake(self.contentView.frame.size.width / 2, alertViewTitle.center.y);
                                  
                                  // 重新计算弹窗高度
                                  [self updateCustomViewHeight];
                                }
                                if (enterprise.configInfo
                                        .evaluationProblemFeedback.length > 0) {
                                  self->evaluationProblemFeedback =
                                      enterprise.configInfo
                                          .evaluationProblemFeedback;
                                }
                                self->evaluationType =
                                    enterprise.configInfo.evaluation_type;
                              }];

  CGFloat currentY = alertViewTitle.frame.origin.y +
                     alertViewTitle.frame.size.height +
                     kMXEvaluationVerticalSpacing;
  CGFloat buttonHeight = 0;

  if ([evaluationProblemFeedback isEqualToString:@"open"]) {

    // 添加问题解决状态按钮
    buttonHeight = 44;
    CGFloat buttonWidth =
        (contentView.frame.size.width - 30) / 2; // 左右间距各掅10px，中间10px

    // 创建"问题已解决"按钮
    solvedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    solvedButton.frame = CGRectMake(10, currentY, buttonWidth, buttonHeight);
    [solvedButton setTitle:@"问题已解决" forState:UIControlStateNormal];
    [solvedButton setTitleColor:[UIColor colorWithRed:29 / 255.0
                                                green:39 / 255.0
                                                 blue:84 / 255.0
                                                alpha:1.0]
                       forState:UIControlStateNormal];
    solvedButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    solvedButton.layer.borderWidth = 1.0;
    solvedButton.layer.borderColor = [UIColor colorWithRed:225 / 255.0
                                                     green:229 / 255.0
                                                      blue:240 / 255.0
                                                     alpha:1.0]
                                         .CGColor;
    solvedButton.layer.cornerRadius = 4.0;
    // 当evaluationProblemFeedback == 'open'才显示
    // 添加左侧图标
    UIImage *thumbsUpImage =
        [MXAssetUtil imageFromBundleWithName:@"thumb-up-line"];
    if (thumbsUpImage) {
      [solvedButton setImage:thumbsUpImage forState:UIControlStateNormal];
      // 调整图标与文字之间的间距
      solvedButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
      solvedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);
      solvedButton.contentHorizontalAlignment =
          UIControlContentHorizontalAlignmentCenter;
    }
    [solvedButton addTarget:self
                     action:@selector(solvedButtonTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:solvedButton];

    // 创建"问题未解决"按钮
    unsolvedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unsolvedButton.frame =
        CGRectMake(buttonWidth + 20, currentY, buttonWidth, buttonHeight);
    [unsolvedButton setTitle:@"问题未解决" forState:UIControlStateNormal];
    [unsolvedButton setTitleColor:[UIColor colorWithRed:29 / 255.0
                                                  green:39 / 255.0
                                                   blue:84 / 255.0
                                                  alpha:1.0]
                         forState:UIControlStateNormal];
    unsolvedButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    unsolvedButton.layer.borderWidth = 1.0;
    unsolvedButton.layer.borderColor = [UIColor colorWithRed:225 / 255.0
                                                       green:229 / 255.0
                                                        blue:240 / 255.0
                                                       alpha:1.0]
                                           .CGColor;
    unsolvedButton.layer.cornerRadius = 4.0;
    // 添加左侧图标
    UIImage *thumbsDownImage =
        [MXAssetUtil imageFromBundleWithName:@"thumb-down-line"];
    if (thumbsDownImage) {
      [unsolvedButton setImage:thumbsDownImage forState:UIControlStateNormal];
      // 调整图标与文字之间的间距
      unsolvedButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);
      unsolvedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);
      unsolvedButton.contentHorizontalAlignment =
          UIControlContentHorizontalAlignmentCenter;
    }
    [unsolvedButton addTarget:self
                       action:@selector(unsolvedButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:unsolvedButton];
    
    currentY += buttonHeight + kMXEvaluationVerticalSpacing;
  }

  // 表情容器
  CGFloat emojiContainerHeight = 70;
  UIView *emojiContainer = [[UIView alloc]
      initWithFrame:CGRectMake(0, currentY, contentView.frame.size.width,
                               emojiContainerHeight)];
  [contentView addSubview:emojiContainer];

  // 加载雪碧图资源
  UIImage *spriteSheetImage =
      [MXAssetUtil imageFromBundleWithName:@"evaluation-picker"];

  // 根据evaluationType确定显示的表情数量，默认为3个
  NSInteger emojiCount = (evaluationType == 5) ? 5 : 3;

  // 创建未选中和选中的表情图标
  NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:emojiCount];
  CGFloat emojiSize = 44; // 每个表情大小
  CGFloat spacing = (contentView.frame.size.width - emojiSize * emojiCount) /
                    (emojiCount + 1); // 间距

  // 在雪碧图中表情的大小和位置
  CGFloat spriteEmojiSize = spriteSheetImage.size.width / 5; // 假设每行5个表情
  CGFloat normalRowY = spriteSheetImage.size.height * 0.5; // 未选中表情在第三行
  CGFloat selectedRowY = spriteSheetImage.size.height * 0.8; // 选中表情在第四行

  // 如果是3个表情，使用最后3个表情图标（这样会显示中等和好评价）
  NSInteger startIndex = 0; //(emojiCount == 3) ? 2 : 0;

  // 间隔
  CGFloat step = emojiCount == 3 ? 2 : 1;

  for (int i = 0; i < emojiCount; i++) {
    // 相对于雪碧图的索引，如果是3个表情，则使用最后3个
    NSInteger spriteIndex = startIndex + i * step;

    // 创建表情图像视图 - 均匀分布表情
    UIImageView *emojiView = [[UIImageView alloc]
        initWithFrame:CGRectMake(spacing + i * (emojiSize + spacing),
                                 (emojiContainerHeight - emojiSize) / 2,
                                 emojiSize, emojiSize)];

    // 从雪碧图中裁剪出未选中的表情
    CGRect normalRect = CGRectMake(spriteIndex * spriteEmojiSize, normalRowY,
                                   spriteEmojiSize, spriteEmojiSize);
    CGImageRef normalCGImage =
        CGImageCreateWithImageInRect(spriteSheetImage.CGImage, normalRect);
    UIImage *normalImage = [UIImage imageWithCGImage:normalCGImage
                                               scale:spriteSheetImage.scale
                                         orientation:UIImageOrientationUp];
    CGImageRelease(normalCGImage);

    // 从雪碧图中裁剪出选中的表情
    CGRect selectedRect =
        CGRectMake(spriteIndex * spriteEmojiSize, selectedRowY, spriteEmojiSize,
                   spriteEmojiSize);
    CGImageRef selectedCGImage =
        CGImageCreateWithImageInRect(spriteSheetImage.CGImage, selectedRect);
    UIImage *selectedImage = [UIImage imageWithCGImage:selectedCGImage
                                                 scale:spriteSheetImage.scale
                                           orientation:UIImageOrientationUp];
    CGImageRelease(selectedCGImage);

    // 设置标签和初始图像
    emojiView.image = normalImage;
    emojiView.tag = i; // 这里的tag不变，因为我们还是使用的相对位置保存
    emojiView.contentMode = UIViewContentModeScaleAspectFit;
    emojiView.userInteractionEnabled = YES;

    // 将选中的图像保存到layer的userdata中，方便点击时访问
    objc_setAssociatedObject(emojiView, "selectedImage", selectedImage,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(emojiView, "normalImage", normalImage,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 添加点击手势
    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(emojiTapped:)];
    [emojiView addGestureRecognizer:tapGesture];

    [emojiContainer addSubview:emojiView];
    [imageViews addObject:emojiView];
  }

  emojiImageViews = [imageViews copy];
  currentY += emojiContainerHeight + kMXEvaluationVerticalSpacing;

  // 添加表情评价名称标签
  UILabel *nameLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(20, currentY, contentView.frame.size.width - 40, 30)];
  nameLabel.textAlignment = NSTextAlignmentCenter;
  nameLabel.font = [UIFont systemFontOfSize:15.0];
  nameLabel.textColor = [UIColor darkGrayColor];
  nameLabel.hidden = YES; // 初始状态隐藏
  [contentView addSubview:nameLabel];
  levelNameLabel = nameLabel;
  currentY += 30 + kMXEvaluationElementSpacing;

  // 创建标签容器视图
  UIView *tagContainer = [[UIView alloc]
      initWithFrame:CGRectMake(kMXEvaluationHorizontalSpacing, currentY,
                               contentView.frame.size.width -
                                   kMXEvaluationHorizontalSpacing * 2,
                               50)]; // 初始高度设为50，后面会根据实际内容调整
  tagContainer.hidden = YES; // 初始状态隐藏
  [contentView addSubview:tagContainer];
  tagsContainerView = tagContainer;
  currentY += 50 + kMXEvaluationElementSpacing;

  // 评价输入框 - 添加在标签区域下方
  CGFloat inputHeight = 70; // 设置一个合理的输入框高度
  commentTextField = [[UITextField alloc]
      initWithFrame:CGRectMake(kMXEvaluationHorizontalSpacing, currentY,
                               contentView.frame.size.width -
                                   kMXEvaluationHorizontalSpacing * 2,
                               inputHeight)];
  commentTextField.placeholder = @"你可以输入评价备注(30字以内)";
  commentTextField.delegate = self;
  commentTextField.returnKeyType = UIReturnKeyDone;
  commentTextField.font = [UIFont systemFontOfSize:15.0];
  commentTextField.textColor = [UIColor darkTextColor];
  commentTextField.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
  commentTextField.textAlignment = NSTextAlignmentLeft;
  commentTextField.layer.cornerRadius = 5;
  commentTextField.layer.borderColor =
      [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
  commentTextField.layer.borderWidth = 0.5;
  // 设置最大输入字数为30
  [commentTextField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
  UIView *paddingView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, 10, commentTextField.frame.size.height)];
  commentTextField.leftView = paddingView;
  commentTextField.leftViewMode = UITextFieldViewModeAlways;
  commentTextField.hidden = YES; // 初始隐藏
  [contentView addSubview:commentTextField];

  // 添加点击手势来收起键盘
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
  tapGesture.cancelsTouchesInView = NO; // 不取消其他控件的点击事件
  [contentView addGestureRecognizer:tapGesture];

  // 初始计算并设置自适应高度
  [self updateCustomViewHeight];

  return scrollView;
}

- (void)showEvaluationAlertView {
  if (evaluationAlertView) {
    if (![evaluationAlertView didShowAlertView]) {
      // 显示之前先重置所有状态
      [self resetAllStates];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [self->evaluationAlertView show];
      });
    }
  }

  [MXServiceToViewInterface
      getEnterpriseEvaluationConfig:YES
                           complete:^(MXEvaluationConfig *levelss,
                                      NSError *error) {
                             // 配置评价选项
                             self->levels = levelss;
                           }];
}

- (void)closeButtonTapped:(UIButton *)sender {
  [self resetAllStates];
  [evaluationAlertView close];
}

// 问题已解决按钮点击
- (void)solvedButtonTapped:(UIButton *)sender {
  // 收起键盘（当用户选择解决状态时）
  [commentTextField resignFirstResponder];
  
  selectedSolvedStatus = 1; // 1表示已解决
  [self updateSolvedButtonsStatus];
}

// 问题未解决按钮点击
- (void)unsolvedButtonTapped:(UIButton *)sender {
  // 收起键盘（当用户选择解决状态时）
  [commentTextField resignFirstResponder];
  
  selectedSolvedStatus = 0; // 0表示未解决
  [self updateSolvedButtonsStatus];
}

// 更新解决状态按钮UI
- (void)updateSolvedButtonsStatus {
  // 先恢复默认状态
  [solvedButton setBackgroundColor:[UIColor whiteColor]];
  [solvedButton setTitleColor:[UIColor colorWithRed:29 / 255.0
                                              green:39 / 255.0
                                               blue:84 / 255.0
                                              alpha:1.0]
                     forState:UIControlStateNormal];
  solvedButton.layer.borderWidth = 1.0;
  solvedButton.layer.borderColor = [UIColor colorWithRed:225 / 255.0
                                                   green:229 / 255.0
                                                    blue:240 / 255.0
                                                   alpha:1.0]
                                       .CGColor;

  [unsolvedButton setBackgroundColor:[UIColor whiteColor]];
  [unsolvedButton setTitleColor:[UIColor colorWithRed:29 / 255.0
                                                green:39 / 255.0
                                                 blue:84 / 255.0
                                                alpha:1.0]
                       forState:UIControlStateNormal];
  unsolvedButton.layer.borderWidth = 1.0;
  unsolvedButton.layer.borderColor = [UIColor colorWithRed:225 / 255.0
                                                     green:229 / 255.0
                                                      blue:240 / 255.0
                                                     alpha:1.0]
                                         .CGColor;

  // 根据选中状态更新UI
  if (selectedSolvedStatus == 1) { // 已解决
    [solvedButton setBackgroundColor:[UIColor colorWithRed:238 / 255.0
                                                     green:240 / 255.0
                                                      blue:246 / 255.0
                                                     alpha:1.0]];
    solvedButton.layer.borderColor =
        [UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor;
  } else if (selectedSolvedStatus == 0) { // 未解决
    [unsolvedButton setBackgroundColor:[UIColor colorWithRed:238 / 255.0
                                                       green:240 / 255.0
                                                        blue:246 / 255.0
                                                       alpha:1.0]];
    unsolvedButton.layer.borderColor =
        [UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor;
  }
}

- (void)emojiTapped:(UITapGestureRecognizer *)gesture {
  // 收起键盘（当用户选择表情时）
  [commentTextField resignFirstResponder];
  
  NSInteger tappedIndex = gesture.view.tag;
  UIImageView *tappedEmojiView = (UIImageView *)gesture.view;

  // 查找并重置当前选中的表情(如果有)
  if (selectedEmojiIndex >= 0) {
    // 在对应容器中查找当前选中的表情
    UIView *containerView = tappedEmojiView.superview;
    for (UIView *subview in containerView.subviews) {
      if ([subview isKindOfClass:[UIImageView class]] &&
          subview.tag == selectedEmojiIndex) {
        UIImageView *selectedView = (UIImageView *)subview;
        UIImage *normalImage =
            objc_getAssociatedObject(selectedView, "normalImage");
        if (normalImage) {
          selectedView.image = normalImage;
        }
        break; // 找到并重置后退出循环
      }
    }
  }

  // 判断点击的是否是当前选中的表情
  if (selectedEmojiIndex == tappedIndex) {
    // 取消选中
    selectedEmojiIndex = -1;
    // 隐藏文字标签
    UILabel *label = (UILabel *)levelNameLabel;
    label.hidden = YES;
    // 隐藏标签区域
    tagsContainerView.hidden = YES;
    // 隐藏评价输入框
    commentTextField.hidden = YES;
    // 清空已选标签
    [self clearSelectedTags];
    // 重新计算弹窗高度
    [self updateCustomViewHeight];
    // 注意：不清空评价内容，以便用户重新选择表情时保留评价内容
  } else {
    // 设置新表情为选中状态
    UIImage *selectedImage =
        objc_getAssociatedObject(tappedEmojiView, "selectedImage");
    if (selectedImage) {
      tappedEmojiView.image = selectedImage;
      selectedEmojiIndex = tappedIndex;

      // 更新并显示对应的文字内容和标签
      [self updateLevelNameLabel];

      // 显示评价输入框
      commentTextField.hidden = NO;
      
      // 更新整体布局高度
      [self updateCustomViewHeight];
    }
  }
}

- (void)numberButtonTapped:(UIButton *)sender {
  selectedNumberIndex = sender.tag;

  // 更新所有数字按钮UI状态
  for (int i = 0; i < numberButtons.count; i++) {
    UIButton *button = numberButtons[i];
    if (i == selectedNumberIndex) {
      [button setBackgroundColor:[UIColor colorWithRed:29 / 255.0
                                                 green:176 / 255.0
                                                  blue:132 / 255.0
                                                 alpha:1.0]];
      [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
      [button setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
      [button setTitleColor:[UIColor darkGrayColor]
                   forState:UIControlStateNormal];
    }
  }
}

- (void)submitButtonTapped:(UIButton *)sender {
  // 收起键盘
  if (commentTextField && [commentTextField isFirstResponder]) {
    [commentTextField resignFirstResponder];
  }
  
  if (!self.delegate) {
    return;
  }
  // 只有选择了表情才能提交
  if (selectedEmojiIndex < 0) {
    // 可以添加提示，要求用户选择表情
    [MXToast showToast:[MXBundleUtil localizedStringForKey:
                                         @"mx_evaluation_please_select_level"]
              duration:2
                window:[[UIApplication sharedApplication].windows lastObject]];

    return;
  }

  // 发送评价，将选择的表情索引转换为评分级别
  NSInteger level = 0;
  if (selectedEmojiIndex >= 0) {
    // 将表情索引0-4转换为评分级别
    // 这里需要根据您的业务逻辑调整，比如可能是0=差评，4=好评
    level = selectedEmojiIndex;
  }

  NSString *comment =
      commentTextField.text.length > 0 ? commentTextField.text : @"";

  // 提交选中的标签 ID 数组
  NSArray *selectedTags = [selectedTagIds copy];
  // 这里需要做一个判断
  // 当前选择的表情对应的level 的 is_required 为 true
  if (selectedTags.count == 0 &&
      levels.level_list[selectedEmojiIndex].is_required) {
    [MXToast
        showToast:[MXBundleUtil
                      localizedStringForKey:@"mx_evaluation_please_select_tag"]
         duration:2
           window:[[UIApplication sharedApplication].windows lastObject]];
    return;
  }

  [self.delegate didSelectLevel:level
                evaluation_type:self->evaluationType
                        tag_ids:selectedTags
                        comment:comment
                       resolved:selectedSolvedStatus];
  
  [evaluationAlertView close];
  [self resetAllStates];
}

#pragma mark - CustomIOSAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  // buttonIndex 0是取消按钮，1是确定按钮
  if (buttonIndex == 1) { // 点击确定按钮
    [self submitButtonTapped:nil];
  } else { // 点击取消按钮或关闭按钮
    // 重置所有状态
    [self resetAllStates];
    [alertView close];
  }
}

- (void)resetAllStates {
  // 收起键盘
  if (commentTextField && [commentTextField isFirstResponder]) {
    [commentTextField resignFirstResponder];
  }
  
  // 重置索引变量
  selectedEmojiIndex = -1;
  selectedNumberIndex = -1;
  selectedSolvedStatus = -1;
  
  // 重置文本框
  commentTextField.text = @"";
  commentTextField.hidden = YES;
  
  // 重置标签状态
  [self clearSelectedTags]; // 清空选中的标签
  [self clearTagsForEmojiChange];
  tagsContainerView.hidden = YES;
  
  // 重置表情状态
  // 首先尝试使用emojiImageViews数组
  if (emojiImageViews && emojiImageViews.count > 0) {
    for (UIImageView *emojiView in emojiImageViews) {
      UIImage *normalImage = objc_getAssociatedObject(emojiView, "normalImage");
      if (normalImage) {
        emojiView.image = normalImage;
      }
    }
  } else {
    // 如果emojiImageViews为空，尝试直接在视图层次结构中查找表情图标
    if (evaluationAlertView && evaluationAlertView.dialogView) {
      // 遍历对话框内容视图找到表情容器
      for (UIView *containerView in evaluationAlertView.dialogView.subviews) {
        if ([containerView isKindOfClass:[UIView class]]) {
          // 对每个容器内的所有图像进行清理
          [self resetAllEmojiViewsInView:containerView];
        }
      }
    }
  }
  
  // 重置数字按钮状态
  if (numberButtons) {
    for (UIButton *button in numberButtons) {
      [button setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
      [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
  }
  
  // 重置解决状态按钮
  [self updateSolvedButtonsStatus];
  
  // 重置评价名称标签
  if (levelNameLabel) {
    UILabel *label = (UILabel *)levelNameLabel;
    label.hidden = YES;
    label.text = @"";
  }
  
  // 重新计算弹窗高度，确保界面正确收缩
  [self updateCustomViewHeight];
}

// 更新评价名称标签
- (void)updateLevelNameLabel {
  UILabel *label = (UILabel *)levelNameLabel;

  // 如果没有选中表情，隐藏文字标签
  if (selectedEmojiIndex < 0) {
    label.hidden = YES;
    return;
  }

  NSString *displayName = nil;

  NSArray<MXEvaluationTag *> *tags = nil;

  if (levels) {
    NSArray<MXEvaluationLevel *> *levelArray = levels.level_list;

    if (levelArray && [levelArray isKindOfClass:[NSArray class]] &&
        levelArray.count > 0) {
      if (selectedEmojiIndex < levelArray.count) {
        MXEvaluationLevel *levelObj = levelArray[selectedEmojiIndex];
        if (levelObj && [levelObj isKindOfClass:[MXEvaluationLevel class]]) {
          displayName = levelObj.name;
          tags = levelObj.tags;
        }
      }
    }
  }

  // 设置并显示文字标签
  if (displayName && displayName.length > 0) {
    label.text = displayName;
    label.hidden = NO;
  } else {
    label.hidden = YES;
  }

  // 更新标签显示
  [self updateTagsView:tags];

  // 动态调整视图布局和高度
  [self updateViewLayout];
  [self updateCustomViewHeight];
}

// 清空选中的标签
- (void)clearSelectedTags {
  [selectedTagIds removeAllObjects];
  [tagViewsMap removeAllObjects];
}

// 切换表情时清空选择的标签
- (void)clearTagsForEmojiChange {
  [self clearSelectedTags];
}

// 检查标签是否被选中
- (BOOL)isTagSelected:(NSString *)tagId {
  return [selectedTagIds containsObject:tagId];
}

// 标签点击事件处理
- (void)tagViewTapped:(UITapGestureRecognizer *)gesture {
  // 收起键盘（当用户选择标签时）
  [commentTextField resignFirstResponder];
  
  UIView *tagView = gesture.view;
  NSString *tagId = tagView.accessibilityIdentifier;
  if (!tagId)
    return;

  BOOL isSelected = [self isTagSelected:tagId];

  if (isSelected) {
    // 如果已经选中，取消选中
    [selectedTagIds removeObject:tagId];
    [self updateTagViewAppearance:tagView isSelected:NO];
  } else {
    // 如果未选中，添加选中
    [selectedTagIds addObject:tagId];
    [self updateTagViewAppearance:tagView isSelected:YES];
  }
}

// 更新标签视觉效果
- (void)updateTagViewAppearance:(UIView *)tagView isSelected:(BOOL)isSelected {
  if (isSelected) {
    // 选中状态
    tagView.backgroundColor = [UIColor colorWithRed:29 / 255.0
                                              green:176 / 255.0
                                               blue:132 / 255.0
                                              alpha:1.0]; // 绿色

    // 查找标签内的文本标签并更新颜色
    for (UIView *subview in tagView.subviews) {
      if ([subview isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)subview;
        label.textColor = [UIColor whiteColor];
        break;
      }
    }
  } else {
    // 未选中状态
    tagView.backgroundColor = [UIColor colorWithRed:243 / 255.0
                                              green:244 / 255.0
                                               blue:249 / 255.0
                                              alpha:1.0]; // 浅灰蓝色

    // 查找标签内的文本标签并更新颜色
    for (UIView *subview in tagView.subviews) {
      if ([subview isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)subview;
        label.textColor = [UIColor colorWithRed:79 / 255.0
                                          green:89 / 255.0
                                           blue:108 / 255.0
                                          alpha:1.0]; // 深色文字
        break;
      }
    }
  }
}

// 更新标签视图
- (void)updateTagsView:(NSArray<MXEvaluationTag *> *)tagsArray {
  // 清除现有标签
  for (UIView *subview in [tagsContainerView subviews]) {
    [subview removeFromSuperview];
  }
  [tagViews removeAllObjects];
  [tagViewsMap removeAllObjects];

  // 如果标签数组为空，隐藏容器
  if (!tagsArray || tagsArray.count == 0) {
    tagsContainerView.hidden = YES;
    return;
  }

  // 表情切换时清空选择的标签
  [self clearTagsForEmojiChange];

  CGFloat tagHeight = 28.0f;
  CGFloat margin = 10.0f;
  CGFloat horizontalPadding = 10.0f;
  CGFloat verticalSpacing = 10.0f;  // 标签之间的垂直间距
  CGFloat horizontalSpacing = 8.0f; // 标签之间的水平间距
  CGFloat containerWidth = tagsContainerView.frame.size.width;
  CGFloat contentWidth = containerWidth - (margin * 2);
  CGFloat totalHeight = margin;

  UIFont *tagFont = [UIFont systemFontOfSize:12.0];

  // 第一步：计算每个标签的宽度并收集有效标签
  NSMutableArray *validTags = [NSMutableArray array];
  NSMutableArray *tagWidths = [NSMutableArray array];

  for (MXEvaluationTag *tag in tagsArray) {
    if (![tag isKindOfClass:[MXEvaluationTag class]] || !tag.name ||
        tag.name.length == 0) {
      continue;
    }

    // 计算标签宽度
    CGSize textSize =
        [tag.name boundingRectWithSize:CGSizeMake(contentWidth, tagHeight)
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:@{NSFontAttributeName : tagFont}
                               context:nil]
            .size;
    CGFloat tagWidth = ceil(textSize.width) + horizontalPadding * 2;

    [validTags addObject:tag];
    [tagWidths addObject:@(tagWidth)];
  }

  // 第二步：分行布局
  NSMutableArray<NSMutableArray *> *lines = [NSMutableArray array];
  NSMutableArray *currentLine = [NSMutableArray array];
  NSMutableArray *currentLineWidths = [NSMutableArray array];
  CGFloat currentLineWidth = 0;

  for (NSInteger i = 0; i < validTags.count; i++) {
    CGFloat tagWidth = [tagWidths[i] floatValue];

    // 检查是否需要开始新行
    BOOL isFirstInLine = (currentLine.count == 0);
    CGFloat widthWithSpacing =
        tagWidth + (isFirstInLine ? 0 : horizontalSpacing);

    if (!isFirstInLine &&
        (currentLineWidth + widthWithSpacing > contentWidth)) {
      // 当前行放不下了，需要开始新行
      [lines addObject:currentLine];
      [lines addObject:currentLineWidths];

      currentLine = [NSMutableArray array];
      currentLineWidths = [NSMutableArray array];
      currentLineWidth = 0;
      isFirstInLine = YES;
      widthWithSpacing = tagWidth;
    }

    [currentLine addObject:validTags[i]];
    [currentLineWidths addObject:@(tagWidth)];
    currentLineWidth += widthWithSpacing;
  }

  // 添加最后一行
  if (currentLine.count > 0) {
    [lines addObject:currentLine];
    [lines addObject:currentLineWidths];
  }

  // 第三步：渲染标签，每行居中对齐
  CGFloat currentY = margin;

  for (NSInteger lineIndex = 0; lineIndex < lines.count; lineIndex += 2) {
    NSArray *lineTags = lines[lineIndex];
    NSArray *lineWidths = lines[lineIndex + 1];

    // 计算当前行的总宽度（包括标签间间距）
    CGFloat totalLineWidth = 0;
    for (NSInteger i = 0; i < lineWidths.count; i++) {
      totalLineWidth += [lineWidths[i] floatValue];
      if (i < lineWidths.count - 1) {
        totalLineWidth += horizontalSpacing;
      }
    }

    // 计算行的起始 X 坐标，使整行居中
    CGFloat startX = (containerWidth - totalLineWidth) / 2;
    CGFloat currentX = startX;

    // 渲染当前行的标签
    for (NSInteger i = 0; i < lineTags.count; i++) {
      MXEvaluationTag *tag = lineTags[i];
      CGFloat tagWidth = [lineWidths[i] floatValue];

      // 创建标签背景视图
      UIView *tagView = [[UIView alloc]
          initWithFrame:CGRectMake(currentX, currentY, tagWidth, tagHeight)];
      tagView.backgroundColor = [UIColor colorWithRed:243 / 255.0
                                                green:244 / 255.0
                                                 blue:249 / 255.0
                                                alpha:1.0]; // 调整为浅灰蓝色
      tagView.layer.cornerRadius = 4.0;

      // 设置标签ID作为识别符
      if (tag.id) { // 使用标签名称作为识别符
        NSInteger tagId = tag.id;
        NSString *tagIdString = [NSString stringWithFormat:@"%ld", (long)tagId];
        tagView.accessibilityIdentifier = tagIdString;

        // 将标签视图保存到映射关系中
        [tagViewsMap setObject:tagView forKey:tagIdString];
      }

      // 添加点击手势
      UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(tagViewTapped:)];
      [tagView addGestureRecognizer:tapGesture];
      tagView.userInteractionEnabled = YES;

      [tagsContainerView addSubview:tagView];
      [tagViews addObject:tagView];

      // 创建标签文本
      UILabel *tagLabel =
          [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tagWidth, tagHeight)];
      tagLabel.text = tag.name;
      tagLabel.font = tagFont;
      tagLabel.textColor = [UIColor colorWithRed:79 / 255.0
                                           green:89 / 255.0
                                            blue:108 / 255.0
                                           alpha:1.0]; // 与设计图一致
      tagLabel.textAlignment = NSTextAlignmentCenter;
      [tagView addSubview:tagLabel];

      // 更新X坐标到下一个标签的位置
      currentX += tagWidth + horizontalSpacing;
    }

    // 更新Y坐标到下一行
    currentY += tagHeight + verticalSpacing;
    totalHeight = currentY;
  }

  // 调整容器高度，减去最后多出的一个垂直间距
  totalHeight -= verticalSpacing;
  totalHeight += margin; // 添加底部的margin

  CGRect frame = tagsContainerView.frame;
  frame.size.height = totalHeight;
  tagsContainerView.frame = frame;
  tagsContainerView.hidden = NO;
}

// 限制输入字数为30字
- (void)textFieldDidChange:(UITextField *)textField {
  NSString *toBeString = textField.text;
  NSString *lang = [textField.textInputMode primaryLanguage];

  if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入特殊处理
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position =
        [textField positionFromPosition:selectedRange.start offset:0];

    // 没有高亮选中的文字，则对当前输入的文字进行字数限制
    if (!position) {
      if (toBeString.length > 30) {
        textField.text = [toBeString substringToIndex:30];
      }
    }
  } else { // 其他语言直接限制长度
    if (toBeString.length > 30) {
      textField.text = [toBeString substringToIndex:30];
    }
  }
}

// 动态调整视图布局
- (void)updateViewLayout {
  UILabel *label = (UILabel *)levelNameLabel;
  CGFloat currentY = label.frame.origin.y;

  // 如果评价名称标签可见，更新当前Y位置
  if (!label.hidden) {
    currentY = label.frame.origin.y + label.frame.size.height +
               kMXEvaluationElementSpacing;
  }

  // 调整标签容器位置
  CGRect tagFrame = tagsContainerView.frame;
  tagFrame.origin.y = currentY;
  tagsContainerView.frame = tagFrame;

  // 更新当前Y位置（只有当标签容器可见时）
  if (!tagsContainerView.hidden) {
    currentY = tagsContainerView.frame.origin.y +
               tagsContainerView.frame.size.height +
               kMXEvaluationElementSpacing;
  }

  // 调整评价输入框位置
  CGRect commentFrame = commentTextField.frame;
  commentFrame.origin.y = currentY;
  commentTextField.frame = commentFrame;
}

// 更新自定义视图高度
- (void)updateCustomViewHeight {
  if (!self.scrollView || !self.contentView) {
    return;
  }
  
  CGFloat bottomPadding = 20; // 底部预留空间
  CGFloat maxContentHeight = 0;
  CGFloat maxHeight = 500; // 设置最大高度为500
  
  // 先调整布局确保所有元素位置正确
  [self updateViewLayout];
  
  // 遍历内容视图的所有子视图，找到最大的Y坐标
  for (UIView *subview in self.contentView.subviews) {
    if (!subview.hidden) {
      CGFloat subviewMaxY = CGRectGetMaxY(subview.frame);
      maxContentHeight = MAX(maxContentHeight, subviewMaxY);
    }
  }
  
  // 计算实际需要的内容高度
  CGFloat contentHeight = maxContentHeight + bottomPadding;
  
  // 更新 contentView 的高度
  CGRect contentFrame = self.contentView.frame;
  contentFrame.size.height = contentHeight;
  self.contentView.frame = contentFrame;
  
  // 设置 scrollView 的 contentSize
  self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, contentHeight);
  
  // 更新 scrollView 的高度
  CGRect scrollFrame = self.scrollView.frame;
  scrollFrame.size.height = MIN(contentHeight, maxHeight);
  self.scrollView.frame = scrollFrame;
  
  // 当内容不超过最大高度时，禁用滚动
  self.scrollView.scrollEnabled = (contentHeight > maxHeight);
  
  // 通知CustomIOSAlertView重新布局对话框
  [self updateAlertViewLayout];
}

// 触发CustomIOSAlertView重新布局
- (void)updateAlertViewLayout {
  if (evaluationAlertView && evaluationAlertView.dialogView && evaluationAlertView.containerView) {
    dispatch_async(dispatch_get_main_queue(), ^{
      UIView *dialogView = self->evaluationAlertView.dialogView;
      UIView *containerView = self->evaluationAlertView.containerView;
      
      // 重新计算对话框大小
      CGSize screenSize = [UIScreen mainScreen].bounds.size;
      CGFloat buttonHeight = 50; // kCustomIOSAlertViewDefaultButtonHeight
      CGFloat buttonSpacerHeight = 1; // kCustomIOSAlertViewDefaultButtonSpacerHeight
      
      CGFloat dialogWidth = containerView.frame.size.width;
      CGFloat dialogHeight = containerView.frame.size.height + buttonHeight + buttonSpacerHeight;
      
      // 更新dialogView的frame
      CGRect newDialogFrame = CGRectMake((screenSize.width - dialogWidth) / 2, 
                                       (screenSize.height - dialogHeight) / 2, 
                                       dialogWidth, 
                                       dialogHeight);
      
      [UIView animateWithDuration:0.2f animations:^{
        dialogView.frame = newDialogFrame;
        
        // 更新背景渐变层的大小
        for (CALayer *layer in dialogView.layer.sublayers) {
          if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = dialogView.bounds;
            break;
          }
        }
        
        // 重新定位按钮和分隔线
        NSMutableArray *buttons = [NSMutableArray array];
        for (UIView *subview in dialogView.subviews) {
          if ([subview isKindOfClass:[UIButton class]]) {
            [buttons addObject:subview];
          }
        }
        
        // 重新计算和设置按钮位置
        CGFloat buttonWidth = dialogWidth / buttons.count;
        for (int i = 0; i < buttons.count; i++) {
          UIButton *button = buttons[i];
          CGRect buttonFrame = CGRectMake(i * buttonWidth, 
                                        dialogHeight - buttonHeight, 
                                        buttonWidth, 
                                        buttonHeight);
          button.frame = buttonFrame;
          
          // 确保按钮样式保持不变
          button.layer.cornerRadius = 7; // kCustomIOSAlertViewCornerRadius
        }
        
        // 重新定位和调整分隔线
        for (UIView *subview in dialogView.subviews) {
          if (subview.backgroundColor && 
              CGColorEqualToColor(subview.backgroundColor.CGColor, 
                                [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f].CGColor)) {
            CGRect lineFrame = subview.frame;
            
            // 检查是否是水平分隔线（按钮上方）
            if (lineFrame.size.width > lineFrame.size.height) {
              lineFrame.origin.y = dialogHeight - buttonHeight - buttonSpacerHeight;
              lineFrame.size.width = dialogWidth;
              lineFrame.size.height = buttonSpacerHeight;
            } else {
              // 垂直分隔线（按钮之间）
              lineFrame.origin.y = dialogHeight - buttonHeight;
              lineFrame.size.height = buttonHeight;
            }
            subview.frame = lineFrame;
          }
        }
      }];
    });
  }
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [commentTextField resignFirstResponder];
  return false;
}

// 点击其他区域收起键盘
- (void)dismissKeyboard:(UITapGestureRecognizer *)gesture {
  // 直接让输入框失去焦点，键盘会自动收起
  [commentTextField resignFirstResponder];
}

// 递归查找并重置视图层次中的所有表情图标
- (void)resetAllEmojiViewsInView:(UIView *)view {
  // 遍历当前视图的所有子视图
  for (UIView *subview in view.subviews) {
    // 如果是图像视图且有手势识别器（表情图标特征）
    if ([subview isKindOfClass:[UIImageView class]] && subview.gestureRecognizers.count > 0) {
      UIImageView *imageView = (UIImageView *)subview;
      
      // 尝试获取关联的正常图像
      UIImage *normalImage = objc_getAssociatedObject(imageView, "normalImage");
      if (normalImage) {
        imageView.image = normalImage;
      }
    }
    
    // 递归查找子视图的子视图
    if (subview.subviews.count > 0) {
      [self resetAllEmojiViewsInView:subview];
    }
  }
}

// 我们不再使用tableView来展示评价选项，所以移除相关代理方法

@end
