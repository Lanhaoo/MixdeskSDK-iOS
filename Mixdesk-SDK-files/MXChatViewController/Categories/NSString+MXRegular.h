//
//  NSString+MXRegular.h
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 Mixdesk. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MXRegular)

- (BOOL)mx_isQQ;

- (BOOL)mx_isPhoneNumber;

- (BOOL)mx_isTelNumber;

/**
 * 去掉<a><span><html> 标签
 */
- (NSString*)mx_textContent;

@end

NS_ASSUME_NONNULL_END
