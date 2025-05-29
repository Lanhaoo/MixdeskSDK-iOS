//
//  MXEvaluationResultCellModel.h
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 16/3/1.
//  Copyright © 2016年 ijinmao. All rights reserved.
//
/**
 * MXEvaluationCellModel 定义了评价 cell
 * 的基本类型数据，包括产生cell的内部所有view的显示数据，cell内部元素的frame等
 * @warning MXEvaluationCellModel 必须满足 MXCellModelProtocol 协议
 */
#import "MXCellModelProtocol.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MixdeskSDK/MixdeskSDK.h>

extern CGFloat const kMXEvaluationCellFontSize;

@interface MXEvaluationResultCellModel : NSObject <MXCellModelProtocol>

/**
 * @brief cell的高度
 */
@property(nonatomic, readonly, assign) CGFloat cellHeight;

/**
 * @brief 评价的等级
 */
@property(nonatomic, readonly, assign) NSInteger level;

/**
 * @brief 评价的 3 | 5
 */
@property(nonatomic, readonly, assign) NSInteger evaluation_type;

/**
 * @brief 评价的标签数组
 */
@property(nonatomic, readonly, copy) NSArray *tag_ids;

/**
 * @brief 标签名称数组
 */
@property(nonatomic, readonly, copy) NSArray *tagNames;

/**
 * @brief 评价的评论
 */
@property(nonatomic, readonly, copy) NSString *comment;

/**
 * @brief 评价是否解决
 */
@property(nonatomic, readonly, assign) NSInteger resolved;

/**
 * @brief 评价等级文本
 */
@property(nonatomic, readonly, copy) NSString *levelText;

/**
 * @brief 解决状态文本
 */
@property(nonatomic, readonly, copy) NSString *resolvedText;

/**
 * @brief 解决状态文本框架
 */
@property(nonatomic, readonly, assign) CGRect resolvedLabelFrame;

/**
 * @brief 等级图片的 frame
 */
@property(nonatomic, readonly, assign) CGRect evaluationImageFrame;

/**
 * @brief 评价 level label 的 frame
 */
@property(nonatomic, readonly, assign) CGRect evaluationTextLabelFrame;

/**
 * @brief 评价等级 label 的 frame
 */
@property(nonatomic, readonly, assign) CGRect evaluationLabelFrame;

/**
 * @brief 标签行的 frame
 */
@property(nonatomic, readonly, assign) CGRect tagsLabelFrame;

/**
 * @brief 评价评论的 frame
 */
@property(nonatomic, readonly, assign) CGRect commentLabelFrame;

/**
 * @brief 消息气泡中的文字的frame
 */
 @property (nonatomic, readonly, assign) CGRect textLabelFrame;

/**
 * @brief 消息气泡中的文字的text
 */
@property (nonatomic, readonly, copy) NSString *text;


/**
 * @brief 评价的时间
 */
@property(nonatomic, readonly, copy) NSDate *date;

/**
 * @brief 评价 label 的 color
 */
@property(nonatomic, readonly, strong) id evaluationLabelColor;

- (MXEvaluationResultCellModel *)initCellModelWithEvaluation:(NSInteger)level
                                             evaluation_type:
                                                 (NSInteger)evaluation_type
                                                     tag_ids:(NSArray *)tag_ids
                                                     comment:(NSString *)comment
                                                    resolved:(NSInteger)resolved
                                                   cellWidth:(CGFloat)cellWidth
                                                   evaluationLevels: (MXEvaluationConfig *)evaluationLevels;

@end
