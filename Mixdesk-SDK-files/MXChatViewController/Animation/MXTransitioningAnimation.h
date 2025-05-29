//
//  MXTransitioningAnimation.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/3/20.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXAnimatorPush.h"
#import "MXShareTransitioningDelegateImpl.h"
#import "MXChatViewConfig.h"

@interface MXTransitioningAnimation : NSObject

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl;

+ (CATransition *)createPresentingTransiteAnimation:(MXTransiteAnimationType)animation;

+ (CATransition *)createDismissingTransiteAnimation:(MXTransiteAnimationType)animation;

+ (void)setInteractive:(BOOL)interactive;

+ (BOOL)isInteractive;

+ (void)updateInteractiveTransition:(CGFloat)percent;

+ (void)cancelInteractiveTransition;

+ (void)finishInteractiveTransition;

@end
