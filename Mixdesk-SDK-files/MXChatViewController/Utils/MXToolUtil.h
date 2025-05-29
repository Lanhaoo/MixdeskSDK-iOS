//
//  MXToolUtil.h
//  Mixdesk-SDK-Demo
//
//  Created by xulianpeng on 2017/10/26.
//  Copyright © 2017年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MXToolUtil : NSObject
+ (NSString*)kMXObtainDeviceVersion;
+ (BOOL)kMXObtainDeviceVersionIsIphoneX;
+ (CGFloat)kMXObtainNaviBarHeight;
+ (CGFloat)kMXObtainStatusBarHeight;
+ (CGFloat)kMXObtainNaviHeight;
+ (CGFloat)kMXScreenWidth;
+ (CGFloat)kMXScreenHeight;
@end
