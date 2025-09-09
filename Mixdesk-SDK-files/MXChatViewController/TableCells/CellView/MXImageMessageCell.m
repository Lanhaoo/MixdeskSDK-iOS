//
//  MXImageMessageCell.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXImageMessageCell.h"
#import "MXImageCellModel.h"
#import "MXChatFileUtil.h"
#import "MXImageUtil.h"
#import "MXChatViewConfig.h"
#import "MXBundleUtil.h"
#import "MXQuickBtnView.h"
#import "MXServiceToViewInterface.h"

@implementation MXImageMessageCell {
    UIImageView *avatarImageView;
    UIImageView *bubbleImageView;
    UIImageView *bubbleContentImageView;
    UIActivityIndicatorView *sendingIndicator;
    UIImageView *failureImageView;
    UIActivityIndicatorView *loadingIndicator;
    
    MXImageCellModel *cellModel;
    
    // 快捷按钮视图
    UIView *quickBtnView;
    
    // 已读状态指示器
    UIImageView *readStatusIndicatorView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 清理快捷按钮视图
    if (quickBtnView) {
        [quickBtnView removeFromSuperview];
        quickBtnView = nil;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        //初始化气泡
        bubbleImageView = [[UIImageView alloc] init];
        UILongPressGestureRecognizer *longPressBubbleGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBubbleView:)];
        [bubbleImageView addGestureRecognizer:longPressBubbleGesture];
        bubbleImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleTapped)];
        [bubbleImageView addGestureRecognizer:tapGesture];
        
        [self.contentView addSubview:bubbleImageView];
        
        //初始化contentImageView
        bubbleContentImageView = [[UIImageView alloc] init];
        bubbleContentImageView.layer.masksToBounds = true;
        bubbleContentImageView.layer.cornerRadius = 6.0;
        [bubbleImageView addSubview:bubbleContentImageView];
        //初始化indicator
        sendingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        sendingIndicator.hidden = YES;
        [self.contentView addSubview:sendingIndicator];
        //初始化出错image
        failureImageView = [[UIImageView alloc] initWithImage:[MXChatViewConfig sharedConfig].messageSendFailureImage];
        UITapGestureRecognizer *tapFailureImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFailImage:)];
        failureImageView.userInteractionEnabled = true;
        [failureImageView addGestureRecognizer:tapFailureImageGesture];
        [self.contentView addSubview:failureImageView];
        //初始化加载数据的indicator
        loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.hidden = YES;
        [bubbleImageView addSubview:loadingIndicator];
        
        //初始化已读状态指示器
        readStatusIndicatorView = [[UIImageView alloc] init];
        readStatusIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
        readStatusIndicatorView.hidden = YES;
        [self.contentView addSubview:readStatusIndicatorView];
    }
    return self;
}

#pragma MXChatCellProtocol
- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
    if (![model isKindOfClass:[MXImageCellModel class]]) {
        NSAssert(NO, @"传给MXImageMessageCell的Model类型不正确");
        return ;
    }
    cellModel = (MXImageCellModel *)model;

    //刷新头像
    if (cellModel.avatarImage) {
        avatarImageView.image = cellModel.avatarImage;
    }
    avatarImageView.frame = cellModel.avatarFrame;
    if ([MXChatViewConfig sharedConfig].enableRoundAvatar) {
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = cellModel.avatarFrame.size.width / 2;
    }
    
    //刷新气泡
    bubbleImageView.frame = cellModel.bubbleImageFrame;
    
    //消息图片
    loadingIndicator.frame = cellModel.loadingIndicatorFrame;
    if (cellModel.image) {
        if ([MXChatViewConfig sharedConfig].enableMessageImageMask) {
            bubbleImageView.image = cellModel.image;
            [MXImageUtil makeMaskView:bubbleImageView withImage:cellModel.bubbleImage];
        } else {
            bubbleImageView.userInteractionEnabled = true;
            bubbleImageView.image = cellModel.bubbleImage;
            bubbleContentImageView.image = cellModel.image;
            bubbleContentImageView.frame = cellModel.contentImageViewFrame;
        }
        
        loadingIndicator.hidden = true;
        [loadingIndicator stopAnimating];
    } else {
        bubbleImageView.image = cellModel.bubbleImage;
        loadingIndicator.hidden = false;
        [loadingIndicator startAnimating];
    }
    
    //刷新indicator
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == MXChatMessageSendStatusSending && cellModel.cellFromType == MXChatCellOutgoing) {
        sendingIndicator.hidden = false;
        sendingIndicator.frame = cellModel.sendingIndicatorFrame;
        [sendingIndicator startAnimating];
    }
    
    //刷新出错图片
    failureImageView.hidden = true;
    if (cellModel.sendStatus == MXChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
    
    // 处理快捷按钮
    // 先移除旧的快捷按钮视图
    if (quickBtnView) {
        [quickBtnView removeFromSuperview];
        quickBtnView = nil;
    }
    
    // 添加新的快捷按钮视图
    if (cellModel.cacheQuickBtnView) {
        quickBtnView = cellModel.cacheQuickBtnView;
        
        // 计算快捷按钮的位置，应该在气泡下方
        CGFloat quickBtnY = CGRectGetMaxY(bubbleImageView.frame) + 8.0; // 8.0是间距
        
        [quickBtnView setFrame:CGRectMake(
            CGRectGetMinX(bubbleImageView.frame),
            quickBtnY,
            quickBtnView.frame.size.width,
            quickBtnView.frame.size.height)];
        
        [self.contentView addSubview:quickBtnView];
    }
    
    // 更新已读状态指示器
    [self updateReadStatusIndicator:cellModel];
}


#pragma 长按事件
- (void)longPressBubbleView:(id)sender {
    if (((UILongPressGestureRecognizer*)sender).state == UIGestureRecognizerStateBegan) {
        [self showMenuControllerInView:self targetRect:bubbleImageView.frame menuItemsName:@{@"imageCopy" : bubbleImageView.image}];
    }
}

#pragma 单击气泡
- (void)bubbleTapped {
    
    UIView *view = self;
    
    while (![view isKindOfClass:[UITableView class]]) {
        view = view.superview;
    }
    
    [cellModel showImageViewerFromRect:[bubbleImageView.superview convertRect:bubbleImageView.frame toView:[UIApplication sharedApplication].keyWindow]];
}

#pragma 点击发送失败消息 重新发送事件
- (void)tapFailImage:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[MXBundleUtil localizedStringForKey:@"retry_send_message"] message:nil delegate:self cancelButtonTitle:[MXBundleUtil localizedStringForKey:@"alert_view_cancel"] otherButtonTitles:[MXBundleUtil localizedStringForKey:@"alert_view_confirm"], nil];
    [alertView show];
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.chatCellDelegate resendMessageInCell:self resendData:@{@"image" : bubbleImageView.image}];
    }
}

#pragma mark - 已读状态指示器

// 创建已送达状态图标（空心圆，边框#bbb）
- (UIImage *)createDeliveredStatusImage {
    CGFloat size = 12.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置边框颜色 #bbb
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 1.0);
    
    // 画空心圆
    CGContextAddEllipseInRect(context, CGRectMake(0.5, 0.5, size-1, size-1));
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 创建已读状态图标（圆形背景#bbb + 白色勾号）
- (UIImage *)createReadStatusImage {
    CGFloat size = 12.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填充圆形背景 #bbb
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, size, size));
    
    // 画白色勾号
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    // 勾号路径
    CGContextMoveToPoint(context, size * 0.25, size * 0.5);
    CGContextAddLineToPoint(context, size * 0.45, size * 0.7);
    CGContextAddLineToPoint(context, size * 0.75, size * 0.3);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 更新已读状态指示器
- (void)updateReadStatusIndicator:(MXImageCellModel *)cellModel {
    readStatusIndicatorView.hidden = YES;
    
    // 只有发送消息且启用了状态显示才显示指示器
    if (cellModel.cellFromType != MXChatCellOutgoing || ![MXServiceToViewInterface isAgentToClientMsgStatus] || cellModel.readStatus == nil) {
        return;
    }
    
    NSInteger status = [cellModel.readStatus integerValue];
    UIImage *statusImage = nil;
    
    switch (status) {
        case 2: // 已送达
            statusImage = [self createDeliveredStatusImage];
            break;
        case 3: // 已读
            statusImage = [self createReadStatusImage];
            break;
        default:
            return;
    }
    
    if (statusImage) {
        readStatusIndicatorView.image = statusImage;
        readStatusIndicatorView.frame = cellModel.readStatusIndicatorFrame;
        readStatusIndicatorView.hidden = NO;
        readStatusIndicatorView.backgroundColor = [UIColor clearColor];
        [self.contentView bringSubviewToFront:readStatusIndicatorView];
    }
}

@end
