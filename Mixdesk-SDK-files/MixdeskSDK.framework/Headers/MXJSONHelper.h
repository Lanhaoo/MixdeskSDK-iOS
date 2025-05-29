//
//  NSObject+JSON.h
//  MixdeskSDK
//
//  Created by ian luo on 16/4/7.
//  Copyright © 2016年 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXJSONHelper:NSObject

+ (NSString *)JSONStringWith:(id)obj;

+ (id)createWithJSONString:(NSString *)jsonString;

@end
