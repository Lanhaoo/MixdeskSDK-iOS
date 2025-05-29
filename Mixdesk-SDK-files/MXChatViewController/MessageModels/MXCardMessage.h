//
//  MXCardMessage.h
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXCardMessage : MXBaseMessage

@property (nonatomic, strong) NSArray *cardData;

@end

NS_ASSUME_NONNULL_END
