//
//  MXHybridViewModel.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXCellModelProtocol.h"

@class MXHybridMessage;
@interface MXHybridViewModel : NSObject /* <MXCellModelProtocol> */

// //与 UI 绑定的数据变化回调
// @property (nonatomic, copy) CGFloat(^cellHeight)(void);
// @property (nonatomic, copy) void(^modelChanges)(NSString *summary, NSString *iconPath, NSString *content);

// //暴露给 UI 的模型数据
// @property (nonatomic, copy) NSString *summary;
// @property (nonatomic, copy) NSString *content;
// @property (nonatomic, copy) NSString *iconPath;

// - (id)initCellModelWithMessage:(MXHybridMessage *)message cellWidth:(CGFloat)cellWidth delegate:(id<MXCellModelDelegate>)delegator;

@end
