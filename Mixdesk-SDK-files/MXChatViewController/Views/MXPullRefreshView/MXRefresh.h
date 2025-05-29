//
//  MXRefresh.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 2017/2/20.
//  Copyright © 2017年 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - UITableView(MXRefresh)
/*
@class MXRefresh;
@interface UITableView(MXRefresh)

@property (nonatomic) MXRefresh *refreshView;

- (void)setupPullRefreshWithAction:(void(^)(void))action;
- (void)startAnimation;
- (void)stopAnimationCompletion:(void(^)(void))action;
- (void)setLoadEnded;

@end
*/
#import "MXChatTableView.h"
@class MXRefresh;
@interface MXChatTableView (MXRefresh)

@property (nonatomic) MXRefresh *refreshView;
- (void)setupPullRefreshWithAction:(void(^)(void))action;
- (void)startAnimation;
- (void)stopAnimationCompletion:(void(^)(void))action;
- (void)setLoadEnded;

@end


/****xlp分割*****/
typedef NS_ENUM(NSUInteger, MXRefreshStatus) {
    MXRefreshStatusNormal,
    MXRefreshStatusDraging,
    MXRefreshStatusTriggered,
    MXRefreshStatusLoading,
    MXRefreshStatusEnd,
};

#pragma mark - MXRefresh

@interface MXRefresh : UIView

@property (nonatomic, assign, readonly) MXRefreshStatus status;

- (BOOL)updateCustomViewForStatus:(MXRefreshStatus)status;
- (void)updateTextForStatus:(MXRefreshStatus)status;
- (void)setLoadEnd;
- (void)updateStatusWithTopOffset:(CGFloat)topOffset;
- (void)setText:(NSString *)text forStatus:(MXRefreshStatus)status;
- (void)setView:(UIView *)view forStatus:(MXRefreshStatus)status;
- (void)setIsLoading:(BOOL)isLoading;

@end
