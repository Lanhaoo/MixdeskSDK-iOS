//
//  MXVisialMessageFactory.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXMessageFactoryHelper.h"

@interface MXVisialMessageFactory : NSObject <MXMessageFactory>

- (MXBaseMessage *)createMessage:(MXMessage *)plainMessage;

@end
