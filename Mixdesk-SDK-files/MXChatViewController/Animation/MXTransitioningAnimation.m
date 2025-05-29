//
//  MXTransitioningAnimation.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/3/20.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXTransitioningAnimation.h"

@interface MXTransitioningAnimation()

@property (nonatomic, strong) MXShareTransitioningDelegateImpl <UIViewControllerTransitioningDelegate> * transitioningDelegateImpl;

@end


@implementation MXTransitioningAnimation

///使用 singleton 的原因是使用这个 transition 的对象并没有维护这个 transition 对象，如果被释放 transition 则会失效，为了减少自定义 transition 对使用者的侵入，只好使用 singleton 来保持该对象
+ (instancetype)sharedInstance {
    static MXTransitioningAnimation *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MXTransitioningAnimation new];
    });
    
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.transitioningDelegateImpl = [MXShareTransitioningDelegateImpl new];
    }
    return self;
}

+ (void)setInteractive:(BOOL)interactive {
    [MXTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive = interactive;
}

+ (BOOL)isInteractive {
    return [MXTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive;
}

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl {
    return [[self sharedInstance] transitioningDelegateImpl];
}

+ (void)updateInteractiveTransition:(CGFloat)percent {
    [[MXTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning updateInteractiveTransition:percent];
}

+ (void)cancelInteractiveTransition {
    [[MXTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning cancelInteractiveTransition];
    [MXTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning = nil;
}

+ (void)finishInteractiveTransition {
    [[MXTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning finishInteractiveTransition];
    [[MXTransitioningAnimation sharedInstance].transitioningDelegateImpl finishTransition];
    
}

#pragma mark -

+ (CATransition *)createPresentingTransiteAnimation:(MXTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case MXTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            break;
        case MXTransiteAnimationTypeDefault:
        default:
            break;
    }
    return transition;
}
+ (CATransition *)createDismissingTransiteAnimation:(MXTransiteAnimationType)animation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    switch (animation) {
        case MXTransiteAnimationTypePush:
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromLeft;
            break;
        case MXTransiteAnimationTypeDefault:
        default:
            break;
    }
    return transition;
}


@end
