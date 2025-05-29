//
//  MXPhotoCardMessage.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXPhotoCardMessage.h"

@implementation MXPhotoCardMessage

-(instancetype)initWithImagePath:(NSString *)path andUrlPath:(NSString *)url {
    if (self = [super init]) {
        self.imagePath = path;
        self.targetUrl  = url;
    }
    return self;
}


@end
