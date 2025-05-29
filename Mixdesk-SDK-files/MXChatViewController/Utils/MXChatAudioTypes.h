//
//  AudioTypes.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/4/19.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#ifndef AudioTypes_h
#define AudioTypes_h


#endif /* AudioTypes_h */

#import <AVFoundation/AVFoundation.h>

///控制声音播放的模式
typedef NS_ENUM(NSUInteger, MXPlayMode) {
    MXPlayModePauseOther = 0, //暂停其他音频
    MXPlayModeMixWithOther = AVAudioSessionCategoryOptionMixWithOthers, //和其他音频同时播放
    MXPlayModeDuckOther = AVAudioSessionCategoryOptionDuckOthers //降低其他音频的声音
};


///控制声音录制的模式
typedef NS_ENUM(NSUInteger, MXRecordMode) {
    MXRecordModePauseOther = 0, //暂停其他音频
    MXRecordModeMixWithOther = AVAudioSessionCategoryOptionMixWithOthers, //和其他音频同时播放
    MXRecordModeDuckOther = AVAudioSessionCategoryOptionDuckOthers //降低其他音频的声音
};