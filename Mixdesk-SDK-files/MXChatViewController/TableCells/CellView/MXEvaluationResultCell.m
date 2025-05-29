//
//  MXEvaluationResultCell.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 16/3/1.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXEvaluationResultCell.h"
#import "MXAssetUtil.h"
#import "MXEvaluationResultCellModel.h"
#import "MXImageUtil.h"
#import <UIKit/UIKit.h>

@implementation MXEvaluationResultCell {
  UILabel *textLabel;               // 1. 用于显示"你已评价"文本
  UIImageView *statusImageView;     // 2. 解决状态图标(赞/踩)
  UILabel *resolvedLabel;           // 3. 问题已解决/未解决文本
  UIImageView *evaluationImageView; // 4. 评价表情图标
  UILabel *evaluationTextLabel;     // 5. 满意度文本
  UILabel *evaluationLabel;         // 评价标签容器
  UIView *tagsContainerView;        // 标签容器视图（第二行）
  UILabel *commentLabel;            // 评论文本（第三行）
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    // 1. 初始化"你已评价"标签
    textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont systemFontOfSize:kMXEvaluationCellFontSize];
    textLabel.textColor = [UIColor darkGrayColor];
    textLabel.textAlignment = NSTextAlignmentCenter;

    // 2. 初始化解决状态图标视图(赞/踩)
    statusImageView = [[UIImageView alloc] init];
    statusImageView.contentMode = UIViewContentModeScaleAspectFit;

    // 3. 初始化解决状态标签
    resolvedLabel = [[UILabel alloc] init];
    resolvedLabel.font = [UIFont systemFontOfSize:kMXEvaluationCellFontSize];
    resolvedLabel.textColor = [UIColor darkGrayColor];
    resolvedLabel.textAlignment = NSTextAlignmentCenter;

    // 4. 初始化评价标签和表情图标
    evaluationLabel = [[UILabel alloc] init];
    evaluationImageView = [[UIImageView alloc] init];
    evaluationImageView.contentMode = UIViewContentModeScaleAspectFit;

    // 5. 初始化满意度文本
    evaluationTextLabel = [[UILabel alloc] init];
    evaluationTextLabel.font =
        [UIFont systemFontOfSize:kMXEvaluationCellFontSize];
    evaluationTextLabel.textColor = [UIColor darkGrayColor];

    // 初始化评论标签
    commentLabel = [[UILabel alloc] init];
    commentLabel.font = [UIFont systemFontOfSize:kMXEvaluationCellFontSize];
    commentLabel.textColor = [UIColor darkGrayColor];
    commentLabel.textAlignment = NSTextAlignmentCenter;
    commentLabel.numberOfLines = 0;

    // 初始化标签容器视图
    tagsContainerView = [[UIView alloc] init];
    tagsContainerView.backgroundColor = [UIColor clearColor];
    
  // 添加到视图层次结构 - 按照顺序添加
    [self.contentView addSubview:textLabel];       // 1. 你已评价
    [self.contentView addSubview:statusImageView]; // 2. 赞/踩图标
    [self.contentView addSubview:resolvedLabel]; // 3. 问题已解决/未解决
    [self.contentView addSubview:evaluationImageView]; // 4. 表情图标
    [self.contentView addSubview:evaluationTextLabel]; // 5. 满意度文本
    [self.contentView addSubview:tagsContainerView];  // 标签容器
    [self.contentView addSubview:commentLabel];        // 评论文本
  }
  return self;
}

#pragma mark - MXChatCellProtocol
- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
  if (![model isKindOfClass:[MXEvaluationResultCellModel class]]) {
    NSAssert(NO, @"传给MXEvaluationResultCell的Model类型不正确");
    return;
  }

  MXEvaluationResultCellModel *cellModel = (MXEvaluationResultCellModel *)model;
  
  // 1. 设置“你已评价”文本
  textLabel.frame = cellModel.textLabelFrame;
  textLabel.text = cellModel.text;

  // 2. 设置赞/踩图标和解决状态文本
  if (cellModel.resolvedText.length > 0) {
    statusImageView.frame = cellModel.evaluationImageFrame;

    if (cellModel.resolved == 1) {
      statusImageView.image = [MXAssetUtil getEvaluationLikeImage];
    } else {
      statusImageView.image = [MXAssetUtil getEvaluationDislikeImage];
    }
    statusImageView.hidden = NO;

    resolvedLabel.frame = cellModel.resolvedLabelFrame;
    resolvedLabel.text = cellModel.resolvedText;
    resolvedLabel.hidden = NO;
  } else {
    statusImageView.hidden = YES;
    resolvedLabel.hidden = YES;
  }

  // 3. 首先设置评价等级文本 - 这是重点
  evaluationTextLabel.frame = cellModel.evaluationTextLabelFrame;
  evaluationTextLabel.text = cellModel.levelText;
  
  // 强制布局更新，确保评价文本位置已更新
  [evaluationTextLabel setNeedsLayout];
  [evaluationTextLabel layoutIfNeeded];
  
  // 4. 设置表情图标 - 固定在评价文本左侧5像素处
  NSInteger level = cellModel.level;
  CGFloat emojiSize = 24.0; // 固定大小
  CGFloat fixedGap = 5.0; // 固定间距
  
  // 计算表情图标位置 - 固定在评价文本左侧5像素处
  CGRect emojiFrame = CGRectMake(
      evaluationTextLabel.frame.origin.x - emojiSize - fixedGap, // 评价文本左边5像素
      evaluationTextLabel.frame.origin.y, // 保持与文本同高
      emojiSize, 
      emojiSize);
  
  // 设置表情图标
  evaluationImageView.frame = emojiFrame;
  evaluationImageView.contentMode = UIViewContentModeScaleAspectFit;
  evaluationImageView.clipsToBounds = YES; // 裁剪超出部分
  evaluationImageView.image = [MXAssetUtil getEvaluationImageWithSpriteLevel:level evaluationType:cellModel.evaluation_type];
  evaluationImageView.hidden = NO;
  
  // 5. 设置第二行（标签）- 使用蓝色圆角矩形背景
  tagsContainerView.frame = cellModel.tagsLabelFrame;
  
  // 清除旧的标签视图
  for (UIView *subview in tagsContainerView.subviews) {
    [subview removeFromSuperview];
  }
  
  // 检查是否有标签数据
  if (cellModel.tagNames && cellModel.tagNames.count > 0) {
    // 标签样式配置
    UIColor *tagBgColor = [UIColor colorWithRed:238/255.0 green:240/255.0 blue:246/255.0 alpha:1.0]; // 浅灰背景
    UIColor *tagTextColor = [UIColor darkGrayColor]; // 深灰文字
    CGFloat tagPadding = 8.0; // 标签内部左右padding
    CGFloat tagHeight = 24.0; // 标签高度
    CGFloat tagCornerRadius = 12.0; // 圆角半径
    CGFloat tagSpacing = 8.0; // 标签之间的间距
    CGFloat fontSize = 12.0; // 字体大小
    
    // 计算并创建标签
    CGFloat currentX = 0;
    CGFloat containerWidth = tagsContainerView.frame.size.width;
    CGFloat containerHeight = 0;
    CGFloat lineHeight = tagHeight;
    CGFloat currentLineWidth = 0;
    NSMutableArray *currentLineViews = [NSMutableArray array];
    
    // 创建标签视图
    for (NSString *tagName in cellModel.tagNames) {
      // 创建标签label来计算宽度
      UILabel *tagLabel = [[UILabel alloc] init];
      tagLabel.text = tagName;
      tagLabel.font = [UIFont systemFontOfSize:fontSize];
      tagLabel.textColor = tagTextColor;
      tagLabel.textAlignment = NSTextAlignmentCenter;
      
      // 计算标签宽度
      CGSize tagSize = [tagName sizeWithAttributes:@{NSFontAttributeName: tagLabel.font}];
      CGFloat tagWidth = tagSize.width + (tagPadding * 2);
      
      // 检查是否需要换行
      if (currentX + tagWidth > containerWidth && currentX > 0) {
        // 居中当前行的标签
        CGFloat offsetX = (containerWidth - currentLineWidth) / 2;
        for (UIView *tagView in currentLineViews) {
          CGRect frame = tagView.frame;
          frame.origin.x += offsetX;
          tagView.frame = frame;
        }
        
        // 重置为新行
        currentX = 0;
        containerHeight += lineHeight + 5; // 5是行间距
        [currentLineViews removeAllObjects];
      }
      
      // 创建标签背景视图
      UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(currentX, containerHeight, tagWidth, tagHeight)];
      tagView.backgroundColor = tagBgColor;
      tagView.layer.cornerRadius = tagCornerRadius;
      tagView.layer.borderWidth = 1.0;
      tagView.layer.borderColor = [UIColor colorWithRed:238/255.0 green:240/255.0 blue:246/255.0 alpha:1.0].CGColor; // 与背景色相同的边框颜色
      tagView.clipsToBounds = YES;
      
      // 将label添加到标签视图
      tagLabel.frame = tagView.bounds;
      [tagView addSubview:tagLabel];
      
      [tagsContainerView addSubview:tagView];
      [currentLineViews addObject:tagView];
      
      // 更新下一个标签的X位置
      currentX += tagWidth + tagSpacing;
      currentLineWidth = currentX - tagSpacing; // 减去最后一个标签后的间距
    }
    
    // 处理最后一行的居中
    CGFloat offsetX = (containerWidth - currentLineWidth) / 2;
    for (UIView *tagView in currentLineViews) {
      CGRect frame = tagView.frame;
      frame.origin.x += offsetX;
      tagView.frame = frame;
    }
    
    // 更新容器高度
    containerHeight += lineHeight;
    CGRect containerFrame = tagsContainerView.frame;
    containerFrame.size.height = containerHeight;
    tagsContainerView.frame = containerFrame;
    
    // 更新容器高度，后续会根据这个高度来调整标签位置
    
    tagsContainerView.hidden = NO;
  } else {
    // 没有标签数据时隐藏
    tagsContainerView.hidden = YES;
  }
  
  // 6. 设置第三行（评论）
  // 同时需要考虑标签容器的实际高度
  
  // 检查是否有评论数据
  if (cellModel.comment.length > 0) {
    // 如果有标签并且标签容器可见，将评论放在标签容器下方
    if (!tagsContainerView.hidden) {
      // 计算评论标签的新位置，在标签容器下方
      CGRect newCommentFrame = cellModel.commentLabelFrame;
      newCommentFrame.origin.y = CGRectGetMaxY(tagsContainerView.frame) + 8.0; // 8像素的间距
      commentLabel.frame = newCommentFrame;
    } else {
      // 没有标签时使用默认的评论标签位置
      commentLabel.frame = cellModel.commentLabelFrame;
    }
    
    // 设置评论文本和样式
    commentLabel.text = cellModel.comment;
    commentLabel.textColor = [UIColor darkGrayColor];
    commentLabel.textAlignment = NSTextAlignmentCenter;
    commentLabel.font = [UIFont systemFontOfSize:14.0];
    commentLabel.hidden = NO;
  } else {
    // 没有评论时隐藏
    commentLabel.hidden = YES;
  }
}

@end
