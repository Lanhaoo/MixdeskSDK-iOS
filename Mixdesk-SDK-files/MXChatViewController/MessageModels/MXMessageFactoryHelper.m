//
//  MXMessageFactoryHelper.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXMessageFactoryHelper.h"
#import "MXEventMessageFactory.h"
#import "MXVisialMessageFactory.h"

@implementation MXMessageFactoryHelper

+ (id<MXMessageFactory>)factoryWithMessageAction:(MXMessageAction)action
                                     contentType:
                                         (MXMessageContentType)contenType
                                        fromType:(MXMessageFromType)fromType {
  if (action == MXMessageActionMessage ||
      action == MXMessageActionAgentSendCard) {
    return [MXVisialMessageFactory new];
  } else {
    return [MXEventMessageFactory new];
  }
}

@end
