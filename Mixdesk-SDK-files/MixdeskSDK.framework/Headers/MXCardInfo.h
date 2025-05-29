//
//  MXCardInfo.h
//  MixdeskSDK
//
//  Created by qipeng_yuhao on 2020/5/25.
//  Copyright © 2020 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXCardInfoMeta : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *value;

@end

typedef enum : NSUInteger {
    MXMessageCardTypeText                    = 0, // 文本
    MXMessageCardTypeDateTime                = 1, // 时间
    MXMessageCardTypeRadio                   = 2, // 单选框
    MXMessageCardTypeCheckbox                  = 3, // 复选框
    MXMessageCardTypeNone                  = 4
} MXMessageCardType;


@interface MXCardInfo : NSObject

@property (nonatomic, copy) NSString * label;

@property (nonatomic, strong) NSArray<MXCardInfoMeta *> *metaData;

@property (nonatomic, strong) NSArray<MXCardInfoMeta *> *metaInfo;

@property (nonatomic, copy) NSString * name;

@property (nonatomic, assign) NSInteger contentId;

@property (nonatomic, assign) MXMessageCardType cardType;


- (id)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
