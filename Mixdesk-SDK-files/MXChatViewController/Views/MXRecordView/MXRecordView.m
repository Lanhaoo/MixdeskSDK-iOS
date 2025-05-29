//
//  MXRecordView.m
//  MeChatSDK
//
//  Created by Injoy on 14/11/13.
//  Copyright (c) 2014年 MeChat. All rights reserved.
//

#import "MXRecordView.h"
#import "MIXDESK_FBLCDFontView.h"
#import "MXNamespacedDependencies.h"
#import "MXImageUtil.h"
#import "MXChatFileUtil.h"
#import "MXToast.h"
#import "MXChatAudioRecorder.h"
#import "MXAssetUtil.h"
#import "MXBundleUtil.h"
#import "MXChatViewConfig.h"

static CGFloat const kMXRecordViewDiameter = 150.0;
static CGFloat const kMXVolumeViewTopMargin = 16.0;
//最大时长的误差修正，这里主要是解决最大时长的文件读出的时长与配置最大市场不准确的问题；这里写的不好，请开发者指正；
static NSInteger const kMXMaxRecordVoiceDurationDeviation = 2;

@interface MXRecordView()<MXChatAudioRecorderDelegate>

@end

@implementation MXRecordView
{
    UIView* blurView;
    UIView* recordView;
    UIImageView* volumeView;
    UILabel* tipLabel;
    FBLCDFontView *LCDView;
    
    UIImage* blurImage;
    BOOL isVisible;
    
    CGFloat recordTime; //录音时长
    NSTimer *recordTimer;
    MXChatAudioRecorder *audioRecorder;
    NSInteger maxVoiceDuration;
}

-(instancetype)initWithFrame:(CGRect)frame maxRecordDuration:(NSTimeInterval)duration
{
    if (self = [super initWithFrame:frame]) {
        maxVoiceDuration = duration;
        self.revoke = NO;
        self.layer.masksToBounds = YES;
        recordView = [[UIView alloc] init];
        recordView.layer.cornerRadius = 10;
        recordView.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
        
        blurView = [[UIView alloc] init];
        volumeView = [[UIImageView alloc] init];
        
        tipLabel = [[UILabel alloc] init];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.font = [UIFont boldSystemFontOfSize:14];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([MXChatViewConfig sharedConfig].enableVoiceRecordBlurView) {
            [self addSubview:blurView];
        }
        [self addSubview:recordView];
        [recordView addSubview:volumeView];
        [recordView addSubview:tipLabel];
        
        audioRecorder = [[MXChatAudioRecorder alloc] initWithMaxRecordDuration:duration+kMXMaxRecordVoiceDurationDeviation];
        audioRecorder.delegate = self;
    }
    return self;
}

- (void)setRecordMode:(MXRecordMode)recordMode {
    audioRecorder.recordMode = recordMode;
}

- (MXRecordMode)recordMode {
    return audioRecorder.recordMode;
}

- (void)setKeepSessionActive:(BOOL)keepSessionActive {
    audioRecorder.keepSessionActive = keepSessionActive;
}

- (BOOL)keepSessionActive {
    return audioRecorder.keepSessionActive;
}

-(void)setRevoke:(BOOL)revoke
{
    if (revoke != self.revoke) {
        if (revoke) {
            tipLabel.text = [MXBundleUtil localizedStringForKey:@"record_cancel_realse"];
            volumeView.image = [MXAssetUtil recordBackImage];
        }else{
            tipLabel.text = [MXBundleUtil localizedStringForKey:@"record_cancel_swipe"];
            volumeView.image = [MXAssetUtil recordVolume:0];
        }
    }
    _revoke = revoke;
}

-(void)setupUI
{
    recordView.frame = CGRectMake((self.frame.size.width - kMXRecordViewDiameter) / 2,
                                  (self.frame.size.height - kMXRecordViewDiameter) / 2,
                                  kMXRecordViewDiameter, kMXRecordViewDiameter);
    self.marginBottom = self.frame.size.height - recordView.frame.origin.y - recordView.frame.size.height;
    recordView.alpha = 0;
    
    tipLabel.text = [MXBundleUtil localizedStringForKey:@"record_cancel_swipe"];
    tipLabel.frame = CGRectMake(0, kMXRecordViewDiameter - 20 - 12, recordView.frame.size.width, 20);
    
    UIImage *volumeImage = [MXAssetUtil recordVolume:0];
    CGFloat volumeViewHeight = ceilf(recordView.frame.size.height * 4 / 7);
    CGFloat volumeViewWidth = ceilf(volumeImage.size.width / volumeImage.size.height * volumeViewHeight);
    volumeView.frame = CGRectMake(recordView.frame.size.width/2 - volumeViewWidth/2, kMXVolumeViewTopMargin, volumeViewWidth, volumeViewHeight);
    volumeView.image = [MXAssetUtil recordVolume:0];
    
    [UIView animateWithDuration:.2 animations:^{
        recordView.alpha = 1;
    }];
}

- (void)reDisplayRecordView {
    self.hidden = NO;
    if (![MXChatViewConfig sharedConfig].enableVoiceRecordBlurView) {
        return;
    }
    if ([recordView.superview isEqual:self]) {
        [recordView removeFromSuperview];
    }
    if ([blurView.superview isEqual:self]) {
        [blurView removeFromSuperview];
    }
    blurImage = [[MXImageUtil viewScreenshot:self.superview] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self addSubview:blurView];
    [self addSubview:recordView];
    blurView.frame = CGRectMake(0, 0, blurImage.size.width, blurImage.size.height);
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurView.layer.contents = (id)blurImage.CGImage;

    if (blurImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            UIImage *blur = [MXImageUtil blurryImage:blurImage
                                       withBlurLevel:.2
                                       exclusionPath:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];
                transition.duration = .2;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                
                [blurView.layer addAnimation:transition forKey:nil];
                blurView.layer.contents = (id)blur.CGImage;
                
                [self setNeedsLayout];
                [self layoutIfNeeded];
            });
        });
    }
}

//-(void)didMoveToSuperview
//{
//    if (!isVisible) {
//        [self setupUI];
//        isVisible = YES;
//    }
//}

-(void)startRecording
{
    if (!recordTimer) {
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recodTime) userInfo:nil repeats:YES];
    }
    recordTime = 0;
    [audioRecorder beginRecording];
}

-(void)recodTime
{
    recordTime = recordTime + 0.1;
    if (recordTime >= maxVoiceDuration + kMXMaxRecordVoiceDurationDeviation - 10) {
        volumeView.alpha = 0;
        if (LCDView) {
            [LCDView removeFromSuperview];
            LCDView = nil;
        }
        LCDView = [[FBLCDFontView alloc] initWithFrame:volumeView.frame];
        LCDView.lineWidth = 4.0;
        LCDView.drawOffLine = NO;
        LCDView.edgeLength = 30;
        LCDView.margin = 0.0;
        LCDView.backgroundColor = [UIColor clearColor];
        LCDView.horizontalPadding = 20;
        LCDView.verticalPadding = 14;
        LCDView.glowSize = 10.0;
        LCDView.glowColor = [UIColor whiteColor];
        LCDView.innerGlowColor = [UIColor grayColor];
        LCDView.innerGlowSize = 3.0;
        [recordView addSubview:LCDView];
        LCDView.text = [NSString stringWithFormat:@"%d",(int)(maxVoiceDuration + kMXMaxRecordVoiceDurationDeviation - recordTime)];
        [LCDView resetSize];
    }
    NSLog(@"recordView time = %f", recordTime);
}

-(void)setRecordingVolume:(float)volume
{
    if (!self.revoke) {
        if (volume > .66) {
            volumeView.image = [MXAssetUtil recordVolume:8];
        }else if (volume > .57){
            volumeView.image = [MXAssetUtil recordVolume:7];
        }else if (volume > .48){
            volumeView.image = [MXAssetUtil recordVolume:6];
        }else if (volume > .39){
            volumeView.image = [MXAssetUtil recordVolume:5];
        }else if (volume > .30){
            volumeView.image = [MXAssetUtil recordVolume:4];
        }else if (volume > .21){
            volumeView.image = [MXAssetUtil recordVolume:3];
        }else if (volume > .12){
            volumeView.image = [MXAssetUtil recordVolume:2];
        }else if (volume > .03){
            volumeView.image = [MXAssetUtil recordVolume:1];
        }else{
            volumeView.image = [MXAssetUtil recordVolume:0];
        }
    }
}

//组件终止录音
-(void)stopRecord
{
    if (recordTime < 1 && recordTime >= 0) {
        if (!self.hidden) {
            [MXToast showToast:[MXBundleUtil localizedStringForKey:@"recode_time_too_short"] duration:1 window:self.superview];
        }
        [audioRecorder cancelRecording];
    } else {
        [audioRecorder finishRecording];
    }
    [self setRecordViewToDefaultStatus];
}

//取消录音
- (void)cancelRecording {
    [self setRecordViewToDefaultStatus];
    [audioRecorder cancelRecording];
}

//将录音界面置为默认状态
- (void)setRecordViewToDefaultStatus {
    [recordTimer invalidate];
    recordTimer = nil;
    self.hidden = YES;
    recordTime = 0;
    if (LCDView) {
        [LCDView removeFromSuperview];
    }
    volumeView.alpha = 1.0;
    tipLabel.text = [MXBundleUtil localizedStringForKey:@"record_cancel_swipe"];
    volumeView.image = [MXAssetUtil recordVolume:0];
}

-(void)revokerecord {
    self.hidden = YES;
}

-(void)recordError:(NSError*)error
{
    self.hidden = YES;
}

#pragma MXChatAudioRecorderDelegate
- (void)didFinishRecordingWithAMRFilePath:(NSString *)filePath {
    //通知viewController已完成录音
    if (self.recordViewDelegate) {
        if ([self.recordViewDelegate respondsToSelector:@selector(didFinishRecordingWithAMRFilePath:)]) {
            [self.recordViewDelegate didFinishRecordingWithAMRFilePath:filePath];
        }
    }
    //恢复录音界面
    [self setRecordViewToDefaultStatus];
}

- (void)didUpdateAudioVolume:(Float32)volume {
//    [self setRecordingVolume:volume];
    if ([self.recordViewDelegate respondsToSelector:@selector(didUpdateVolumeInRecordView:volume:)]) {
        [self.recordViewDelegate didUpdateVolumeInRecordView:self volume:volume];
    }
}

- (void)didEndRecording {
    [self stopRecord];
}

- (void)didBeginRecording {
    
}

/** 更新frame */
- (void)updateFrame:(CGRect)frame {
    self.frame = frame;
    recordView.frame = CGRectMake((self.frame.size.width - kMXRecordViewDiameter) / 2,
                                  (self.frame.size.height - kMXRecordViewDiameter) / 2,
                                  kMXRecordViewDiameter, kMXRecordViewDiameter);

}

- (BOOL)isRecording {
    return [audioRecorder isRecording];
}

@end
