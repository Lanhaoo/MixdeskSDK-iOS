//
//  MXChatViewStyle.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/3/29.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXChatViewStyle.h"
#import "MXAssetUtil.h"
#import "MXChatViewStyleBlue.h"
#import "MXChatViewStyleGreen.h"
#import "MXChatViewStyleDark.h"

@interface MXChatViewStyle()

@property (nonatomic, assign) BOOL didSetStatusBarStyle;

@end

@implementation MXChatViewStyle

+ (instancetype)createWithStyle:(MXChatViewStyleType)type {
    switch (type) {
        case MXChatViewStyleTypeBlue:
            return [MXChatViewStyleBlue new];
        case MXChatViewStyleTypeGreen:
            return [MXChatViewStyleGreen new];
        case MXChatViewStyleTypeDark:
            return [MXChatViewStyleDark new];
        default:
            return [MXChatViewStyle new];
    }
}

+ (instancetype)defaultStyle {
    return [self createWithStyle:(MXChatViewStyleTypeDefault)];
}

+ (instancetype)blueStyle {
    return [self createWithStyle:(MXChatViewStyleTypeBlue)];
}

+ (instancetype)darkStyle {
    return [self createWithStyle:(MXChatViewStyleTypeDark)];
}

+ (instancetype)greenStyle {
    return [self createWithStyle:(MXChatViewStyleTypeGreen)];
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.enableRoundAvatar       = false;
        self.enableIncomingAvatar    = true;
        self.enableOutgoingAvatar    = true;

        self.backgroundColor = [UIColor whiteColor];
        self.incomingMsgTextColor   = [UIColor colorWithRed:90/255.0 green:105/255.0 blue:120/255.0 alpha:1];
        self.outgoingMsgTextColor   = [UIColor whiteColor];
        self.eventTextColor         = [UIColor grayColor];
        self.pullRefreshColor       = nil;//[UIColor colorWithRed:104.0/255.0 green:192.0/255.0 blue:160.0/255.0 alpha:1.0];
        self.btnTextColor            = [UIColor mx_colorWithHexWithLong:0x3E8BFF];
        self.redirectAgentNameColor = [UIColor blueColor];
        self.navBarColor            = nil;//[UIColor colorWithHexString:MXBlueColor];
        self.navBarTintColor        = [UIColor mx_colorWithHexWithLong:0x3E8BFF];

        self.incomingBubbleColor    = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:247/255.0 alpha:1];
        self.outgoingBubbleColor    = [UIColor colorWithRed:22/255.0 green:199/255.0 blue:209/255.0 alpha:1];
        self.navTitleColor          = nil;//[UIColor whiteColor];
        
        self.photoSenderImage               = [MXAssetUtil imageFromBundleWithName:@"imageIcon"];
        self.photoSenderHighlightedImage    = nil;
        self.voiceSenderImage               = [MXAssetUtil imageFromBundleWithName:@"micIcon"];
        self.voiceSenderHighlightedImage    = nil;
        self.cameraSenderImage              = [MXAssetUtil imageFromBundleWithName:@"cameraIcon"];
        self.cameraSenderHighlightedImage   = nil;
        self.emojiSenderImage               = [MXAssetUtil imageFromBundleWithName:@"emoji"];
        self.emojiSenderHighlightedImage    = nil;
        self.evaluationSenderImage          = [MXAssetUtil imageFromBundleWithName:@"evaluation"];
        self.evaluationSenderHighlightedImage    = nil;
        self.incomingBubbleImage            = [MXAssetUtil bubbleIncomingImage];
        self.outgoingBubbleImage            = [MXAssetUtil bubbleOutgoingImage];
        self.messageSendFailureImage        = [MXAssetUtil messageWarningImage];
        self.imageLoadErrorImage            = [MXAssetUtil imageLoadErrorImage];
        
        CGPoint stretchPoint                = CGPointMake(self.incomingBubbleImage.size.width / 4.0f, self.incomingBubbleImage.size.height * 3.0f / 4.0f);
        self.bubbleImageStretchInsets       = UIEdgeInsetsMake(stretchPoint.y, stretchPoint.x, self.incomingBubbleImage.size.height-stretchPoint.y+0.5, stretchPoint.x);
                
        self.statusBarStyle                 = UIStatusBarStyleDefault;
        self.didSetStatusBarStyle = false;
    }
    return self;
}


- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _statusBarStyle = statusBarStyle;
    self.didSetStatusBarStyle = YES;
}

@end
