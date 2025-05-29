//
//  MXAssetUtil.h
//  MXChatViewControllerDemo
//
//  Created by Injoy on 15/11/16.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MXAssetUtil : NSBundle

+ (UIImage *)imageFromBundleWithName:(NSString *)name;

+ (UIImage *)templateImageFromBundleWithName:(NSString *)name;

+ (NSString*)resourceWithName:(NSString*)fileName;

+ (UIImage *)incomingDefaultAvatarImage;
+ (UIImage *)outgoingDefaultAvatarImage;

+ (UIImage *)messageCameraInputImage;
+ (UIImage *)messageCameraInputHighlightedImage;

+ (UIImage *)messageTextInputImage;
+ (UIImage *)messageTextInputHighlightedImage;

+ (UIImage *)messageVoiceInputImage;
+ (UIImage *)messageVoiceInputHighlightedImage;

+ (UIImage *)bubbleIncomingImage;
+ (UIImage *)bubbleOutgoingImage;

+ (UIImage *)returnCancelImage;

+ (UIImage *)imageLoadErrorImage;
+ (UIImage *)messageWarningImage;

+ (UIImage *)voiceAnimationGray1;
+ (UIImage *)voiceAnimationGray2;
+ (UIImage *)voiceAnimationGray3;
+ (UIImage *)voiceAnimationGrayError;

+ (UIImage *)voiceAnimationGreen1;
+ (UIImage *)voiceAnimationGreen2;
+ (UIImage *)voiceAnimationGreen3;
+ (UIImage *)voiceAnimationGreenError;

+ (UIImage *)videoPlayImage;

+ (UIImage *)recordBackImage;

+ (UIImage *)recordVolume:(NSInteger)volume;

+ (UIImage *)getEvaluationImageWithLevel:(NSInteger)level;
+ (UIImage *)getEvaluationImageWithSpriteLevel:(NSInteger)level;
+ (UIImage *)getEvaluationImageWithSpriteLevel:(NSInteger)level evaluationType:(NSInteger)evaluationType;

+ (UIImage *)getEvaluationLikeImage;
+ (UIImage *)getEvaluationDislikeImage;

+ (UIImage *)getNavigationMoreImage;

+ (UIImage *)agentOnDutyImage;
+ (UIImage *)agentOffDutyImage;
+ (UIImage *)agentOfflineImage;

+ (UIImage *)fileIcon;
+ (UIImage *)fileCancel;
+ (UIImage *)fileDonwload;
+ (UIImage *)backArrow;
+ (UIImage *)networkStatusError;
+ (UIImage *)networkStatusWarning;
@end
