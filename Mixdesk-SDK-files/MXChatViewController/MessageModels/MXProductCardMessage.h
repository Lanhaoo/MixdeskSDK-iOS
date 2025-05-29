//
//  MXProductCardMessage.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2021/9/1.
//  Copyright © 2021 2020 Mixdesk. All rights reserved.
//

#import "MXBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXProductCardMessage : MXBaseMessage

@property (nonatomic, copy) NSString *pictureUrl;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *productUrl;

@property (nonatomic, assign) long salesCount;

-(instancetype)initWithPictureUrl:(NSString *)pictureUrl
                            title:(NSString *)title
                      description:(NSString *)desc
                       productUrl:(NSString *)productUrl
                    andSalesCount:(long)count;

@end

NS_ASSUME_NONNULL_END
