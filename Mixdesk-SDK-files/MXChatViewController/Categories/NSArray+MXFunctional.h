//
//  NSArray+MXFunctional.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/4/20.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(MXFunctional)

- (NSArray *)filter:(BOOL(^)(id element))action;

- (NSArray *)map:(id(^)(id element))action;

- (id)reduce:(id)initial step:(id(^)(id current, id element))action;

@end
