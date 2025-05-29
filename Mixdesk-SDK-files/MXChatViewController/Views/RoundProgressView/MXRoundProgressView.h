//
//  RoundProgressView.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/27.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXRoundProgressView : UIView

@property (strong, nonatomic) UIColor *progressColor;

@property (assign, nonatomic) BOOL progressHidden;

- (instancetype)initWithFrame:(CGRect)frame centerView:(UIView *)centerView;

- (void)updateProgress:(CGFloat)progress;

@end
