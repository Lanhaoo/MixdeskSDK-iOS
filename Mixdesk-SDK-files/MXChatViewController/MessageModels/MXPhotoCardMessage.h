//
//  MXPhotoCardMessage.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXPhotoCardMessage : MXBaseMessage

@property (nonatomic, copy) NSString *imagePath;

@property (nonatomic, copy) NSString *targetUrl;


-(instancetype)initWithImagePath:(NSString *)path andUrlPath:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
