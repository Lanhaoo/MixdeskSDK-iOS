//
//  MXVoiceMessageCell.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXChatBaseCell.h"

/**
 * MXVoiceMessageCell定义了客服聊天界面的语音消息cell
 */
@interface MXVoiceMessageCell : MXChatBaseCell

/**
 *  开始播放声音
 */
//- (void)playVoice;

/**
 *  停止播放声音
 */
- (void)stopVoiceDisplay;


@end
