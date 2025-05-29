//
//  MXImageMessage.h
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXBaseMessage.h"
#import <UIKit/UIKit.h>

@interface MXImageMessage : MXBaseMessage

@property(nonatomic, strong) NSArray *quickBtns;

/** 消息image path */
@property (nonatomic, copy) NSString *imagePath;

/** 消息image */
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithImagePath:(NSString *)imagePath;

- (instancetype)initWithImage:(UIImage *)image;

@end
