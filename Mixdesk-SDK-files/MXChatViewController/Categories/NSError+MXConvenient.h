//
//  NSError+MXConvenient.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 2017/1/19.
//  Copyright © 2017年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError(MXConvenient)

+ (NSError *)reason:(NSString *)reason;

+ (NSError *)reason:(NSString *)reason code:(NSInteger)code;

+ (NSError *)reason:(NSString *)reason code:(NSInteger) code domain:(NSString *)domain;

- (NSString *)reason;

- (NSString *)shortDescription;

@end
