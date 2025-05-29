//
//  MXVideoPlayerViewController.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/26.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXVideoPlayerViewController.h"
#import "MXChatFileUtil.h"

@interface MXVideoPlayerViewController ()

@property (nonatomic, copy) NSString * mediaPath;

@property (nonatomic, copy) NSString * mediaServerPath;

@end

@implementation MXVideoPlayerViewController

- (instancetype)initPlayerWithLocalPath:(NSString *)localPath serverPath:(NSString *)serverPath {
    if (self = [super init]) {
        self.mediaPath = localPath;
        self.mediaServerPath = serverPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.mediaPath.length > 0 && [MXChatFileUtil fileExistsAtPath:self.mediaPath isDirectory:NO]) {
        self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.mediaPath]];
    } else {
        self.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.mediaServerPath]];
    }
    self.showsPlaybackControls = YES;
}

@end
