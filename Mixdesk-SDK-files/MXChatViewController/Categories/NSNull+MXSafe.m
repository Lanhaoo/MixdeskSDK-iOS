//
//  NSNull+Safe.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/5/31.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "NSNull+MXSafe.h"
#import <objc/runtime.h>

@implementation NSNull(MXSafe)

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (!sig) {
        sig = [NSMethodSignature signatureWithObjCTypes:"^v^c"];
    }
    
    return sig;
}

@end
