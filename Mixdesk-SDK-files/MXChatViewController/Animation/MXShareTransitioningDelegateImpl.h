//
//  MXShareTransitioningDelegateImpl.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/3/20.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MXShareTransitioningDelegateImpl : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning> *interactiveTransitioning;

- (void)finishTransition;
@end
