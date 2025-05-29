//
//  MXEvaluationResultCellModel.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 16/3/1.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXEvaluationResultCellModel.h"
#import "MXAssetUtil.h"
#import "MXBundleUtil.h"
#import "MXEvaluationResultCell.h"
#import "MXStringSizeUtil.h"
#include <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 增加常量定义
// 字体属性常量定义
static NSString *const kNSFontAttributeName = @"NSFont";
static NSString *const kNSParagraphStyleAttributeName = @"NSParagraphStyle";
// 文本绘制选项常量定义
static NSUInteger const kNSStringDrawingUsesLineFragmentOrigin = 1;
// 换行模式常量定义
static NSUInteger const kNSLineBreakByWordWrapping = 0;

static CGFloat const kMXEvaluationCellLabelVerticalMargin = 6.0;
static CGFloat const kMXEvaluationCellLabelHorizontalMargin = 8.0;
static CGFloat const kMXEvaluationCellLabelHorizontalSpacing = 8.0;
static CGFloat const kMXEvaluationCellVerticalSpacing = 12.0;
static CGFloat const kMXEvaluationCommentHorizontalSpacing = 36.0;
CGFloat const kMXEvaluationCellFontSize = 14.0;

@interface MXEvaluationResultCellModel ()

/**
 * @brief cell的高度
 */
@property(nonatomic, readwrite, assign) CGFloat cellHeight;

/**
 * @brief 评价的等级
 */
@property(nonatomic, readwrite, assign) NSInteger level;

/**
 * @brief 评价的 3 | 5
 */
@property(nonatomic, readwrite, assign) NSInteger evaluation_type;

/**
 * @brief 评价的评论
 */
@property(nonatomic, readwrite, copy) NSString *comment;

/**
 * @brief 评价的标签
 */
@property(nonatomic, readwrite, copy) NSArray *tag_ids;

/**
 * @brief 标签名称数组
 */
@property(nonatomic, readwrite, copy) NSArray *tagNames;

/**
 * @brief 标签行的 frame
 */
@property(nonatomic, readwrite, assign) CGRect tagsLabelFrame;

/**
 * @brief 评价是否解决
 */
@property(nonatomic, readwrite, assign) NSInteger resolved;

/**
 * @brief 评价解决状态文本
 */
@property(nonatomic, readwrite, copy) NSString *resolvedText;

/**
 * @brief 评价等级文本
 */
@property(nonatomic, readwrite, copy) NSString *levelText;

/**
 * @brief 解决状态文本框位置
 */
@property(nonatomic, readwrite, assign) CGRect resolvedLabelFrame;

/**
 * @brief 等级图片的 frame
 */
@property(nonatomic, readwrite, assign) CGRect evaluationImageFrame;

/**
 * @brief 评价 level label 的 frame
 */
@property(nonatomic, readwrite, assign) CGRect evaluationTextLabelFrame;

/**
 * @brief 评价等级 label 的 frame
 */
@property(nonatomic, readwrite, assign) CGRect evaluationLabelFrame;

/**
 * @brief 评价评论的 frame
 */
@property(nonatomic, readwrite, assign) CGRect commentLabelFrame;

/**
 * @brief 文字的frame
 */
@property(nonatomic, readwrite, assign) CGRect textLabelFrame;

/**
 * @brief 文字的text
 */
@property(nonatomic, readwrite, copy) NSString *text;

/**
 * @brief 评价的时间
 */
@property(nonatomic, readwrite, copy) NSDate *date;

/**
 * @brief 评价 label 的 color
 */
@property(nonatomic, readwrite, strong) id evaluationLabelColor;

@end

@implementation MXEvaluationResultCellModel

#pragma initialize
/**
 *  根据tips内容来生成cell model
 */
- (MXEvaluationResultCellModel *)
    initCellModelWithEvaluation:(NSInteger)level
                evaluation_type:(NSInteger)evaluation_type
                        tag_ids:(NSArray *)tag_ids
                        comment:(NSString *)comment
                       resolved:(NSInteger)resolved
                      cellWidth:(CGFloat)cellWidth
               evaluationLevels:(MXEvaluationConfig *)evaluationLevels {
  if (self = [super init]) {
    _date = [NSDate date];
    _comment = comment;
    _tag_ids = [tag_ids copy];
    _text = @"你已评价";
    _evaluation_type = evaluation_type;

    // 预计算文本尺寸和图像
    CGFloat tempResolvedTextWidth = 0;
    CGFloat tempResolvedTextHeight = 0;

    // 设置基本属性
    _level = level;
    _resolved = resolved;

    NSString *displayName = nil;

    if (evaluationLevels && level >= 0) {
      NSArray<MXEvaluationLevel *> *levelArray = evaluationLevels.level_list;

      if (levelArray && [levelArray isKindOfClass:[NSArray class]] &&
          levelArray.count > 0) {
        MXEvaluationLevel *levelObj = levelArray[level];
        if (levelObj && [levelObj isKindOfClass:[MXEvaluationLevel class]]) {
          displayName = levelObj.name;
          
          // 获取对应等级的标签数组
          NSArray *tags = levelObj.tags;
          
          // 如果tag_ids有值，查找对应的标签名称
          if (tag_ids && tag_ids.count > 0 && tags && tags.count > 0) {
            NSMutableArray *tagNameArray = [NSMutableArray array];
            
            // 循环遍历tag_ids和tags，找到匹配的标签名称
            for (id tagIdObj in tag_ids) {
              NSString *tagId = nil;
              
              // 处理不同类型的tagId
              if ([tagIdObj isKindOfClass:[NSString class]]) {
                tagId = (NSString *)tagIdObj;
              } else if ([tagIdObj isKindOfClass:[NSNumber class]]) {
                tagId = [(NSNumber *)tagIdObj stringValue];
              }
              
              if (tagId) {
                for (id tagObj in tags) {
                  // 对象可能是字典或自定义类
                  if ([tagObj isKindOfClass:[NSDictionary class]]) {
                    // 字典类型
                    NSDictionary *tagDict = (NSDictionary *)tagObj;
                    if ([[tagDict objectForKey:@"id"] isEqualToString:tagId]) {
                      [tagNameArray addObject:[tagDict objectForKey:@"name"]];
                      break;
                    }
                  } else {
                    // 自定义类型，使用KVC获取属性
                    // MXEvaluationTag类使用id属性而不是tag_id
                    id tagIdValue = [tagObj valueForKey:@"id"];
                    // 转换为字符串进行比较
                    NSString *tagIdString = [NSString stringWithFormat:@"%@", tagIdValue];
                    if ([tagIdString isEqualToString:tagId]) {
                      [tagNameArray addObject:[tagObj valueForKey:@"name"]];
                      break;
                    }
                  }
                }
              }
            }
            
            if (tagNameArray.count > 0) {
              _tagNames = [tagNameArray copy];
            }
          }
        }
      }
    }

    if (displayName && displayName.length > 0) {
      _levelText = displayName;
    }
        // 设置已解决/未解决文本
    if (resolved == 0) {
      _resolvedText = @"问题未解决"; 
    } else if (resolved == 1) {
      _resolvedText = @"问题已解决"; 
    }

    // 计算单行显示所需的尺寸
    CGFloat smallSpacing = 2.0; // 元素之间的间距
    CGFloat spacing = 5.0;      // 元素之间的间距
    CGFloat textHeight = 24.0;  // 所有文本的统一高度
    CGFloat iconSize = 18.0;    // 表情图标的尺寸

    // 计算各元素的宽度 - 使用实际文本长度计算

    // 设置字体和文本样式
    UIFont *textFont = [UIFont systemFontOfSize:kMXEvaluationCellFontSize];
    NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

    // 计算"你已评价"的实际宽度
    NSDictionary *textAttributes = @{
      NSFontAttributeName : textFont,
      NSParagraphStyleAttributeName : paragraphStyle
    };
    CGFloat evaluatedTextWidth =
        [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight)
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:textAttributes
                                context:nil]
            .size.width +
        10.0; // 增加10点的空间

    CGFloat thumbIconWidth = iconSize; // 赞图标宽度

    // 计算"问题已解决/问题未解决"的实际宽度
    CGFloat resolvedTextWidth = 0;
    if (self.resolvedText.length > 0) {
      resolvedTextWidth =
          [self.resolvedText
              boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight)
                           options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:textAttributes
                           context:nil]
              .size.width +
          10.0; // 增加10点的空间
    }

    CGFloat levelIconWidth = iconSize; // 表情图标宽度

    // 计算满意度文本的实际宽度
    CGFloat levelTextWidth = 0;
    if (self.levelText.length > 0) {
      levelTextWidth =
          [self.levelText
              boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight)
                           options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:textAttributes
                           context:nil]
              .size.width +
          10.0; // 增加10点的空间
    } else {
      levelTextWidth = 60.0; // 默认宽度
    }                        // "非常满意"宽度

    // 计算总宽度，根据解决状态是否存在来决定布局
    CGFloat totalWidth = 0;
    BOOL hasResolvedStatus = (resolved == 0 || resolved == 1);

    if (hasResolvedStatus) {
      // 如果有解决状态，包含所有元素
      totalWidth = evaluatedTextWidth + spacing + thumbIconWidth + spacing +
                   resolvedTextWidth + spacing + levelIconWidth + spacing +
                   levelTextWidth;
    } else {
      // 如果没有解决状态，不显示解决状态相关元素
      totalWidth = evaluatedTextWidth + spacing + levelIconWidth + spacing +
                   levelTextWidth;
    }

    // 计算开始位置，使得整行居中
    CGFloat startX = (cellWidth - totalWidth) / 2.0;
    CGFloat currentX = startX;
    CGFloat centerY = kMXEvaluationCellVerticalSpacing + textHeight / 2.0;

    // 1. 设置"你已评价"文本的位置
    self.textLabelFrame = CGRectMake(currentX, kMXEvaluationCellVerticalSpacing,
                                     evaluatedTextWidth, textHeight);
    currentX += evaluatedTextWidth + spacing;

    // 根据解决状态是否存在决定布局
    if (hasResolvedStatus) {
      // 2. 设置赞/踩图标的位置
      self.evaluationImageFrame =
          CGRectMake(currentX, kMXEvaluationCellVerticalSpacing, thumbIconWidth,
                     textHeight);
      currentX += thumbIconWidth + spacing;

      // 3. 设置"问题已解决/未解决"文本的位置
      self.resolvedLabelFrame =
          CGRectMake(currentX, kMXEvaluationCellVerticalSpacing,
                     resolvedTextWidth, textHeight);
      currentX += resolvedTextWidth + spacing;
    } else {
      // 如果没有解决状态，将这些元素设置为零大小，但保留空间必要的变量
      self.evaluationImageFrame = CGRectZero;
      self.resolvedLabelFrame = CGRectZero;
      // 不需要增加currentX，因为这些元素不显示
    }

    // 4. 设置满意度表情图标的位置
    self.evaluationLabelFrame = CGRectMake(
        currentX, kMXEvaluationCellVerticalSpacing, textHeight, textHeight);
    currentX += levelIconWidth + spacing;

    // 5. 设置满意度文本的位置
    self.evaluationTextLabelFrame = CGRectMake(
        currentX, kMXEvaluationCellVerticalSpacing, levelTextWidth, textHeight);

    // 更新单元格总高度 - 第一行显示评价信息，第二行有评论时显示评论

    // 计算第一行下方的起始位置
    CGFloat firstRowHeight = textHeight + kMXEvaluationCellVerticalSpacing;
    CGFloat contentWidth = cellWidth - kMXEvaluationCommentHorizontalSpacing * 2;
    CGFloat verticalSpacing = 10.0; // 行间间隔
    
    // 计算第二行（标签行）的布局
    CGFloat tagsY = firstRowHeight + verticalSpacing;
    CGFloat tagsHeight = 0;
    
    // 检查是否有标签数据
    if (self.tagNames && self.tagNames.count > 0) {
      NSString *tagsString = [self.tagNames componentsJoinedByString:@", "];
      
      // 计算标签文本高度
      UIFont *tagFont = [UIFont systemFontOfSize:kMXEvaluationCellFontSize];
      NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
      paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
      paragraphStyle.alignment = NSTextAlignmentCenter;
      
      NSDictionary *attributes = @{
        kNSFontAttributeName: tagFont,
        kNSParagraphStyleAttributeName: paragraphStyle
      };
      
      CGRect tagTextRect = [tagsString boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
      
      tagsHeight = ceilf(tagTextRect.size.height) + 8.0; // 标签行高度
      
      // 标签行布局
      self.tagsLabelFrame = CGRectMake(kMXEvaluationCommentHorizontalSpacing,
                                       tagsY,
                                       contentWidth,
                                       tagsHeight);
    } else {
      // 没有标签时，设置为空
      self.tagsLabelFrame = CGRectZero;
      tagsHeight = 0;
    }
    
    // 计算第三行（评论行）的布局
    CGFloat commentY = tagsY + tagsHeight + (tagsHeight > 0 ? verticalSpacing : 0);
    CGFloat commentHeight = 0;
    
    // 检查是否有评论内容
    if (comment.length > 0) {
      // 计算评论文本的高度
      UIFont *commentFont = [UIFont systemFontOfSize:kMXEvaluationCellFontSize];
      NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
      paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
      paragraphStyle.alignment = NSTextAlignmentCenter;
      
      NSDictionary *attributes = @{
        kNSFontAttributeName: commentFont,
        kNSParagraphStyleAttributeName: paragraphStyle
      };
      
      CGRect commentTextRect = [comment boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                   options:kNSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
      
      commentHeight = ceilf(commentTextRect.size.height) + 8.0; // 评论行高度
      
      // 设置评论行布局
      self.commentLabelFrame = CGRectMake(kMXEvaluationCommentHorizontalSpacing,
                                         commentY,
                                         contentWidth,
                                         commentHeight);
    } else {
      // 没有评论时，设置为空
      self.commentLabelFrame = CGRectZero;
      commentHeight = 0;
    }

    // 计算整个单元格的高度
    if (self.commentLabelFrame.size.height > 0) {
      // 如果有评论，高度包含到评论行结束
      self.cellHeight = self.commentLabelFrame.origin.y +
                        self.commentLabelFrame.size.height +
                        kMXEvaluationCellVerticalSpacing;
    } else if (self.tagsLabelFrame.size.height > 0) {
      // 如果没有评论但有标签，高度包含到标签行结束
      self.cellHeight = self.tagsLabelFrame.origin.y +
                        self.tagsLabelFrame.size.height +
                        kMXEvaluationCellVerticalSpacing;
    } else {
      // 如果既没有评论也没有标签，高度到第一行结束
      self.cellHeight = firstRowHeight + kMXEvaluationCellVerticalSpacing;
    }
  }
  return self;
}

#pragma MXCellModelProtocol
- (CGFloat)getCellHeight {
  return self.cellHeight > 0 ? self.cellHeight : 0;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
  // 重新计算所有frame
  // 在此示例中，我们只需要重新使用当前值
  // 实际实现可能需要重新计算各元素位置
}

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个MXEvaluationResultCell实例
 */
- (id)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
  // 返回MXEvaluationResultCell实例，这是已经正确实现updateCellWithCellModel:方法的子类
  // 使用直接创建的方式，不依赖UIKit中的类型
  Class cellClass = NSClassFromString(@"MXEvaluationResultCell");
  if (cellClass) {
    return [[cellClass alloc] init];
  }

  // 如果因为某种原因找不到MXEvaluationResultCell类，创建一个远程弹窗提示错误
  NSAssert(NO, @"MXEvaluationResultCell类不存在，请检查项目配置");
  // 返回一个基本对象避免崩溃，不要使用UIKit类型
  return [[NSObject alloc] init];
}

- (NSDate *)getCellDate {
  return self.date;
}

- (BOOL)isServiceRelatedCell {
  return false;
}

- (NSString *)getCellMessageId {
  return @"";
}

- (NSString *)getMessageConversionId {
  return @"";
}

// 已在上面实现了updateCellFrameWithCellWidth:方法

@end
