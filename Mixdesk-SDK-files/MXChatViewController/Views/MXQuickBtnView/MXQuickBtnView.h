//
//  MXQuickBtnView.h
//  MXEcoboostSDK-test
//
//  Created on 2025-05-21.
//  Copyright © 2025 Mixdesk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXRichTextMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXQuickBtnView : UIView

/**
 * 初始化快捷按钮视图
 * @param quickBtns 快捷按钮数组
 * @param maxWidth 最大宽度限制
 * @param convId 对话ID
 */
-(instancetype)initWithQuickBtns:(NSArray *)quickBtns
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
 * 快捷按钮点击回调
 */
@property (nonatomic, copy) void(^mxQuickBtnClickedWithModel)(MXMessageBottomQuickBtnModel *model);

@end

NS_ASSUME_NONNULL_END
