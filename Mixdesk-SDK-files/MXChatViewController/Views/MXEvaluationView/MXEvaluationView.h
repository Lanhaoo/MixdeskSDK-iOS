//
//  MXEvaluationView.h
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 16/1/19.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MXEvaluationViewDelegate <NSObject>

/**
 *  发送了评价
 *  @param level   评价等级 0-差评 1-中评 2-好评
 *  @param comment 评价内容
 *  @param tag_ids  选中的标签 ID 数组
 *  @param evaluation_type 评价的等级 3 | 5
 *  @param resolved 问题解决状态 1-已解决 0-未解决
 */
- (void)didSelectLevel:(NSInteger)level evaluation_type:(NSInteger)evaluation_type tag_ids:(NSArray *)tag_ids comment:(NSString *)comment resolved:(NSInteger)resolved;

@end

@interface MXEvaluationView : NSObject

@property(nonatomic, weak) id<MXEvaluationViewDelegate> delegate;

/**
 *  显示评价的自定义 AlertView
 */
- (void)showEvaluationAlertView;

@end
