//
//  MXVideoPlayerViewController.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/26.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MXVideoPlayerViewController : AVPlayerViewController

- (instancetype)initPlayerWithLocalPath:(NSString *)localPath serverPath:(NSString *)serverPath;

@end

NS_ASSUME_NONNULL_END
