//
//  MXAssetUtil.m
//  MXChatViewControllerDemo
//
//  Created by Injoy on 15/11/16.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "MXAssetUtil.h"
#import "MXBundleUtil.h"
#import "MXChatViewController.h"

@implementation MXAssetUtil

+ (UIImage *)imageFromBundleWithName:(NSString *)name {
  id image =
      [UIImage imageWithContentsOfFile:[MXAssetUtil resourceWithName:name]];
  if (image) {
    return image;
  } else {
    return
        [UIImage imageWithContentsOfFile:[[MXAssetUtil resourceWithName:name]
                                             stringByAppendingString:@".png"]];
  }
}

+ (UIImage *)templateImageFromBundleWithName:(NSString *)name {
  return [[self.class imageFromBundleWithName:name]
      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (NSString *)resourceWithName:(NSString *)fileName {
  //        return [NSString
  //        stringWithFormat:@"MXChatViewAsset.bundle/%@",fileName];
  // 查看 bundle 是否存在
  NSBundle *mixdeskBundle =
      [NSBundle bundleForClass:[MXChatViewController class]];
  NSString *fileRootPath = [[mixdeskBundle bundlePath]
      stringByAppendingString:@"/MXChatViewAsset.bundle"];
  NSString *filePath = [fileRootPath
      stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
  return filePath;
}

+ (UIImage *)incomingDefaultAvatarImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXIcon"];
}

+ (UIImage *)outgoingDefaultAvatarImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXIcon"];
}

+ (UIImage *)messageCameraInputImage {
  return [MXAssetUtil
      imageFromBundleWithName:@"MXMessageCameraInputImageNormalStyleOne"];
}

+ (UIImage *)messageCameraInputHighlightedImage {
  return [MXAssetUtil
      imageFromBundleWithName:@"MXMessageCameraInputImageNormalStyleOne"];
}

+ (UIImage *)messageTextInputImage {
  return [MXAssetUtil
      imageFromBundleWithName:@"MXMessageTextInputImageNormalStyleOne"];
}

+ (UIImage *)messageTextInputHighlightedImage {
  return [MXAssetUtil
      imageFromBundleWithName:@"MXMessageTextInputImageNormalStyleOne"];
}

+ (UIImage *)messageVoiceInputImage {
  return [MXAssetUtil
      imageFromBundleWithName:@"MXMessageVoiceInputImageNormalStyleOne"];
}

+ (UIImage *)messageVoiceInputHighlightedImage {
  return [MXAssetUtil
      imageFromBundleWithName:@"MXMessageVoiceInputImageNormalStyleOne"];
}

+ (UIImage *)bubbleIncomingImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXBubbleIncoming"];
}

+ (UIImage *)bubbleOutgoingImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXBubbleOutgoing"];
}

+ (UIImage *)returnCancelImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXNavReturnCancelImage"];
}

+ (UIImage *)imageLoadErrorImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXImageLoadErrorImage"];
}

+ (UIImage *)messageWarningImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXMessageWarning"];
}

+ (UIImage *)voiceAnimationGray1 {
  return
      [MXAssetUtil imageFromBundleWithName:@"MXBubble_voice_animation_gray1"];
}

+ (UIImage *)voiceAnimationGray2 {
  return
      [MXAssetUtil imageFromBundleWithName:@"MXBubble_voice_animation_gray2"];
}

+ (UIImage *)voiceAnimationGray3 {
  return
      [MXAssetUtil imageFromBundleWithName:@"MXBubble_voice_animation_gray3"];
}

+ (UIImage *)voiceAnimationGrayError {
  return [MXAssetUtil imageFromBundleWithName:@"MXBubble_incoming_voice_error"];
}

+ (UIImage *)voiceAnimationGreen1 {
  return
      [MXAssetUtil imageFromBundleWithName:@"MXBubble_voice_animation_green1"];
}

+ (UIImage *)voiceAnimationGreen2 {
  return
      [MXAssetUtil imageFromBundleWithName:@"MXBubble_voice_animation_green2"];
}

+ (UIImage *)voiceAnimationGreen3 {
  return
      [MXAssetUtil imageFromBundleWithName:@"MXBubble_voice_animation_green3"];
}

+ (UIImage *)voiceAnimationGreenError {
  return [MXAssetUtil imageFromBundleWithName:@"MXBubble_outgoing_voice_error"];
}

+ (UIImage *)videoPlayImage {
  return [MXAssetUtil imageFromBundleWithName:@"message_video_play-icon"];
}

+ (UIImage *)recordBackImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXRecord_back"];
}

+ (UIImage *)recordVolume:(NSInteger)volume {
  NSString *imageName;
  switch (volume) {
  case 0:
    imageName = @"MXRecord0";
    break;
  case 1:
    imageName = @"MXRecord1";
    break;
  case 2:
    imageName = @"MXRecord2";
    break;
  case 3:
    imageName = @"MXRecord3";
    break;
  case 4:
    imageName = @"MXRecord4";
    break;
  case 5:
    imageName = @"MXRecord5";
    break;
  case 6:
    imageName = @"MXRecord6";
    break;
  case 7:
    imageName = @"MXRecord7";
    break;
  case 8:
    imageName = @"MXRecord8";
    break;
  default:
    imageName = @"MXRecord0";
    break;
  }
  return [MXAssetUtil imageFromBundleWithName:imageName];
}

+ (UIImage *)getEvaluationImageWithLevel:(NSInteger)level {
  NSString *imageName = @"MXEvaluationPositiveImage";
  switch (level) {
  case 0:
    imageName = @"MXEvaluationNegativeImage";
    break;
  case 1:
    imageName = @"MXEvaluationModerateImage";
    break;
  case 2:
    imageName = @"MXEvaluationPositiveImage";
    break;
  default:
    break;
  }
  return [MXAssetUtil imageFromBundleWithName:imageName];
}

+ (UIImage *)getEvaluationImageWithSpriteLevel:(NSInteger)level
                                evaluationType:(NSInteger)evaluationType {
  // 获取雪碧图
  UIImage *spriteSheetImage =
      [MXAssetUtil imageFromBundleWithName:@"evaluation-picker"];
  if (!spriteSheetImage) {
    // 雪碧图不存在，使用旧方法
    return [MXAssetUtil getEvaluationImageWithLevel:level];
  }

  // 计算雪碧图中表情的大小和位置
  // 雪碧图宽度除以5（每行5个表情）得到每个表情的宽度
  CGFloat spriteEmojiSize = spriteSheetImage.size.width / 5;

  // 选中的表情图标位于雪碧图的第四行（约为总高度的80%位置）
  CGFloat selectedRowY = spriteSheetImage.size.height * 0.8;

  // 进行索引映射（与评价类型不同，当前只使用3级评价）
  NSInteger spriteIndex = 0;

  if (evaluationType == 3) {
    // 根据level确定表情索引
    switch (level) {
    case 0:
      spriteIndex = 0;
      break;
    case 1:
      spriteIndex = 2;
      break;
    case 2:
      spriteIndex = 4;
      break;
    default:
      break;
    }
  } else {
    spriteIndex = level;
  }

  // 从雪碎图中裁剪出选中的表情
  // 确保提取的区域是正方形且中心对齐
  CGFloat exactSpriteSize = MIN(spriteEmojiSize, spriteEmojiSize); // 确保宽高相等
  
  // 计算表情在雪碎图中的X坐标，并保证居中裁剪
  CGFloat spriteX = spriteIndex * spriteEmojiSize + (spriteEmojiSize - exactSpriteSize) / 2.0;
  CGFloat spriteY = selectedRowY + (spriteEmojiSize - exactSpriteSize) / 2.0;
  
  CGRect selectedRect = CGRectMake(spriteX, spriteY, exactSpriteSize, exactSpriteSize);
  
  // 裁剪前进行边界检查，确保不超出图片范围
  if (CGRectGetMaxX(selectedRect) > spriteSheetImage.size.width) {
    selectedRect.size.width = spriteSheetImage.size.width - selectedRect.origin.x;
  }
  if (CGRectGetMaxY(selectedRect) > spriteSheetImage.size.height) {
    selectedRect.size.height = spriteSheetImage.size.height - selectedRect.origin.y;
  }
  
  CGImageRef selectedCGImage = CGImageCreateWithImageInRect(spriteSheetImage.CGImage, selectedRect);
  UIImage *selectedImage = [UIImage imageWithCGImage:selectedCGImage
                                             scale:1.0
                                       orientation:UIImageOrientationUp];
  CGImageRelease(selectedCGImage);

  return selectedImage;
}

+ (UIImage *)getEvaluationLikeImage {
  return [MXAssetUtil imageFromBundleWithName:@"EvaluationLikeImage"];
}

+ (UIImage *)getEvaluationDislikeImage {
  return [MXAssetUtil imageFromBundleWithName:@"EvaluationDisLikeImage"];
}

+ (UIImage *)getNavigationMoreImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXMessageNavMoreImage"];
}

+ (UIImage *)agentOnDutyImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXAgentStatusOnDuty"];
}

+ (UIImage *)agentOffDutyImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXAgentStatusOffDuty"];
}

+ (UIImage *)agentOfflineImage {
  return [MXAssetUtil imageFromBundleWithName:@"MXAgentStatusOffline"];
}

+ (UIImage *)fileIcon {
  return [MXAssetUtil imageFromBundleWithName:@"fileIcon"];
}

+ (UIImage *)fileCancel {
  return [MXAssetUtil imageFromBundleWithName:@"MXFileCancel"];
}

+ (UIImage *)fileDonwload {
  return [MXAssetUtil imageFromBundleWithName:@"MXFileDownload"];
}

+ (UIImage *)backArrow {
  return [[MXAssetUtil imageFromBundleWithName:@"backArrow"]
      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)networkStatusError {
  return [MXAssetUtil imageFromBundleWithName:@"MXNetworkError"];
}

+ (UIImage *)networkStatusWarning {
  return [MXAssetUtil imageFromBundleWithName:@"MXNetworkWarning"];
}

@end
