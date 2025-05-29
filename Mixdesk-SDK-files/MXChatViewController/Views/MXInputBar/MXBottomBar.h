//
//  MXInputToolView.h
//  Mixdesk
//
//  Created by xulianpeng on 2017/8/31.
//  Copyright © 2017年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXButtonGroupBar.h"
#import "MXInputContentView.h"

@class MXBottomBar;



@protocol MXBottomBarDelegate<NSObject>

@optional
- (void)inputBar:(MXBottomBar *)inputBar willChangeHeight:(CGFloat)height;
- (void)inputBar:(MXBottomBar *)inputBar didChangeHeight:(CGFloat)height;
- (void)textContentDidChange:(NSString *)newString;

@end



@interface MXBottomBar : UIView<MXInputContentViewDelegate, MXInputContentViewLayoutDelegate>


@property (weak, nonatomic) id<MXBottomBarDelegate> delegate;
@property (weak, nonatomic) id<MXInputContentViewDelegate> contentViewDelegate;
@property (weak, nonatomic) id<MXButtonGroupBarDelegate> buttonGroupDelegate;

@property (strong, nonatomic, readonly) MXInputContentView *contentView;

@property (strong, nonatomic, readonly) MXButtonGroupBar *buttonGroupBar;

@property (strong, nonatomic) UIView *inputView;

/** 扩展功能的view，显示在MCButtonGroupBar下面 */
@property (strong, nonatomic, readonly) NSMutableArray<UIView *> *functionViews;
/** 功能View当前是否可见 */
@property (assign, nonatomic, readonly) BOOL functionViewVisible;

- (instancetype)initWithFrame:(CGRect)frame contentView:(MXInputContentView *)contentView;

/**
 *  显示一个functionView
 *
 *  @param index functionViews的下标，用于指定显示哪个functionView
 */
- (void)selectShowFunctionViewWithIndex:(NSInteger)index;

/**
 *  隐藏当前显示的functionView
 */
- (void)hideSelectedFunctionView;

/**
 *  给inputView复制，并设置当InputBar失去焦点时的回调。
 */
- (void)setInputView:(UIView *)inputView resignFirstResponderBlock:(void (^)(void))block;
@end
