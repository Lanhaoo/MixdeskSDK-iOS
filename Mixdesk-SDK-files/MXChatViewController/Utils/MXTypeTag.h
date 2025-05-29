//
//  MXTypeTag.h
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXTypeTag : NSObject

+ (NSInteger)tagWithName:(NSString *)name;

+ (NSString *)nameWithTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
