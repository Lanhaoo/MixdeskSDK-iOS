//
//  MCInputContentView.h
//  Mixdesk
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXInputContentView;

@protocol MXInputContentViewDelegate <NSObject>

@optional
/**
 *  用户点击return
 *
 *  @param content          输入内容
 *  @param object           当前自定义数据
 */
- (BOOL)inputContentViewShouldReturn:(MXInputContentView *)inputContentView content:(NSString *)content userObject:(NSObject *)object;

/**
 *  自定义数据改变
 *
 *  @param object           改变后的数据
 */
- (void)inputContentView:(MXInputContentView *)inputContentView userObjectChange:(NSObject *)object;

- (BOOL)inputContentViewShouldBeginEditing:(MXInputContentView *)inputContentView;

- (void)inputContentTextDidChange:(NSString *)newString;

@end

@protocol MXInputContentViewLayoutDelegate <NSObject>

@optional
- (void)inputContentView:(MXInputContentView *)inputContentView willChangeHeight:(CGFloat)height;
- (void)inputContentView:(MXInputContentView *)inputContentView didChangeHeight:(CGFloat)height;

@end


@interface MXInputContentView : UIView

@property (weak, nonatomic) id<MXInputContentViewDelegate> delegate;
@property (weak, nonatomic) id<MXInputContentViewLayoutDelegate> layoutDelegate;


@property (strong, nonatomic) UIView *inputView;
@property (strong, nonatomic) UIView *inputAccessoryView;

//- (BOOL)isFirstResponder;
//- (BOOL)becomeFirstResponder;
//- (BOOL)resignFirstResponder;

- (UIView *)inputView;
- (void)setInputView:(UIView *)inputview;

- (UIView *)inputAccessoryView;
- (void)setInputAccessoryView:(UIView *)inputAccessoryView;

@end
