//
//  UIColor+Hex.h
//  AutoGang
//
//  Created by luoxu on 14/12/20.
//  Copyright (c) 2014年 com.qcb008.QiCheApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor(MXHex)

+ (UIColor *)mx_colorWithHexWithLong:(long)hexColor alpha:(CGFloat)a;

+ (UIColor *)mx_colorWithHexWithLong:(long)hexColor;

+ (UIColor *)mx_colorWithHexString:(NSString *)hexString;

+ (UIColor *)mx_getDarkerColorFromColor1:(UIColor *)color1 color2:(UIColor *)color2;

@end
