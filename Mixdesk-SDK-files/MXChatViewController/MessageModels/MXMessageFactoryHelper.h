//
//  MXMessageFactoryHelper.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXBaseMessage.h"
#import <MixdeskSDK/MXMessage.h>

@protocol MXMessageFactory <NSObject>

- (MXBaseMessage *)createMessage:(MXMessage *)plainMessage;

@end


@interface MXMessageFactoryHelper : NSObject

+ (id<MXMessageFactory>)factoryWithMessageAction:(MXMessageAction)action contentType:(MXMessageContentType)contenType fromType:(MXMessageFromType)fromType;

@end
