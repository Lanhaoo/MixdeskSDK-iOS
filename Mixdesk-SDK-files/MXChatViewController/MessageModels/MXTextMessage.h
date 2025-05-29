//
//  MXTextMessage.h
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXBaseMessage.h"

@interface MXTextMessage : MXBaseMessage

/** 消息content */
@property (nonatomic, copy) NSString *content;
/** 消息是否包含敏感词汇 */
@property (nonatomic, assign) BOOL isSensitive;
@property (nonatomic, assign) BOOL isHTML;

@property (nonatomic, strong) NSArray *tags;

/**
 * 用文字初始化message
 */
- (instancetype)initWithContent:(NSString *)content;

@end

/**
 *  message的底部工具tag的功能
 *  MXMessageBottomTagTypeCopy - 复制内容
 *  MXMessageBottomTagTypeCall - 拨打电话
 *  MXMessageBottomTagTypeLink - 打开链接
 */
typedef NS_ENUM(NSUInteger, MXMessageBottomTagType) {
    MXMessageBottomTagTypeCopy,
    MXMessageBottomTagTypeCall,
    MXMessageBottomTagTypeLink,
};

@interface MXMessageBottomTagModel : NSObject

/** tag的名称 */
@property (nonatomic, copy) NSString *name;
/** tag的功能 */
@property (nonatomic, assign) MXMessageBottomTagType tagType;
/** tag的内容 */
@property (nonatomic, copy) NSString *value;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
