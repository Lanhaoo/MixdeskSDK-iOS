//
//  MIXDESK_InputView.h
//  Mixdesk-SDK-Demo
//
//  Created by xulianpeng on 2018/1/10.
//  Copyright © 2018年 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>

#define emojikeyboardHeight 260
#define bottomHeight 30 // 底部按钮的高度
#define emojCellWidth  54
#define emojCellHeight 42
#define emojiBackColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]

@protocol MIXDESK_InputViewDelegate  <NSObject>

@optional
- (void)MXInputViewObtainEmojiStr:(NSString *)emojiStr;
- (void)MXInputViewDeleteEmoji;
- (void)MXInputViewSendEmoji;

@end
@interface MIXDESK_InputView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,weak)id<MIXDESK_InputViewDelegate>inputViewDelegate;

@end
