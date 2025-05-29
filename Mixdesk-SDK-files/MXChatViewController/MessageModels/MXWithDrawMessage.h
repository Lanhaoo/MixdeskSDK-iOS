//
//  MXWithDrawMessage.h
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/27.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXWithDrawMessage : MXBaseMessage

/** 消息是否撤回 */
@property (nonatomic, assign) BOOL isMessageWithDraw;

/** 内容 */
@property (nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
