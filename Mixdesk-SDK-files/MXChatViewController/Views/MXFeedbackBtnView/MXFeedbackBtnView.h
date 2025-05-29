//
//  MXFeedbackBtnView.h
//  MXEcoboostSDK-test
//
//  Created on 2025-05-22.
//  Copyright © 2025 Mixdesk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXHybridMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXFeedbackBtnView : UIView

/**
 * 初始化反馈按钮视图
 * @param feedbackBtns 反馈按钮数组
 * @param maxWidth 最大宽度限制
 * @param convId 对话ID
 */
-(instancetype)initWithFeedbackBtns:(NSArray *)feedbackBtns
                           maxWidth:(CGFloat)maxWidth
                             convId:(NSString *)convId;

/**
 * 获取视图高度
 */
-(CGFloat)getViewHeight;

/**
 * 更新最大宽度布局
 */
-(void)updateLayoutWithMaxWidth:(CGFloat)maxWidth;

/**
 * 反馈按钮点击回调
 */
@property (nonatomic, copy) void(^mxFeedbackBtnClickedWithModel)(MXFeedbackButtonModel *model);

@end

NS_ASSUME_NONNULL_END
