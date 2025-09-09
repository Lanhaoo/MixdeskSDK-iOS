//
//  MXVideoMessageCell.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/23.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXVideoMessageCell.h"
#import "MXVideoCellModel.h"
#import "MXChatViewConfig.h"
#import "MXAssetUtil.h"
#import "MXRoundProgressView.h"
#import "MXServiceToViewInterface.h"

@interface MXVideoMessageCell ()
@property (nonatomic, copy) NSString *mediaPath;
@property (nonatomic, copy) NSString *mediaServerPath;
@property (nonatomic, strong) MXRoundProgressView *progressView;
@end

@implementation MXVideoMessageCell {
    UIImageView *avatarImageView;
    UIView *bubbleView;
    UIImageView *bubbleContentImageView;
    UIButton *playBtn;
    UIImageView *failureImageView;
    UIActivityIndicatorView *sendingIndicator;
    MXVideoCellModel *cellModel;
    
    // 已读状态指示器
    UIImageView *readStatusIndicatorView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化头像
        avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:avatarImageView];
        //初始化气泡
        bubbleView = [[UIView alloc] init];
        bubbleView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:247/255.0 alpha:1];
        bubbleView.layer.masksToBounds = true;
        bubbleView.layer.cornerRadius = 6.0;
        [self.contentView addSubview:bubbleView];
        
        //初始化contentImageView
        bubbleContentImageView = [[UIImageView alloc] init];
        bubbleContentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [bubbleView addSubview:bubbleContentImageView];
        //初始化播放按钮
        playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [playBtn setBackgroundImage:[MXAssetUtil videoPlayImage] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(clickPlaybtn) forControlEvents:UIControlEventTouchUpInside];
        
        self.progressView = [[MXRoundProgressView alloc] initWithFrame:CGRectMake(0, 0, kMXCellPlayBtnHeight, kMXCellPlayBtnHeight) centerView:playBtn];
        self.progressView.progressHidden = YES;
        self.progressView.progressColor = [UIColor greenColor];
        [bubbleView addSubview:self.progressView];
        
        
        sendingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        sendingIndicator.hidden = YES;
        [self.contentView addSubview:sendingIndicator];
        //初始化发送失败image
        failureImageView = [[UIImageView alloc] initWithImage:[MXChatViewConfig sharedConfig].messageSendFailureImage];
        UITapGestureRecognizer *tapFailureImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFailImage:)];
        failureImageView.userInteractionEnabled = true;
        [failureImageView setHidden:YES];
        [failureImageView addGestureRecognizer:tapFailureImageGesture];
        [self.contentView addSubview:failureImageView];
        
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
    if (![model isKindOfClass:[MXVideoCellModel class]]) {
        NSAssert(NO, @"传给MXVideoCellModel的Model类型不正确");
        return ;
    }
    cellModel = model;
    self.mediaPath = cellModel.videoPath;
    self.mediaServerPath = cellModel.videoServerPath;
    
    self.progressView.progressHidden = !cellModel.isDownloading;
    __weak typeof(self) weakSelf = self;
    cellModel.progressBlock = ^(float progress) {
        [weakSelf.progressView updateProgress:progress];
    };
    
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
    bubbleView.frame = cellModel.bubbleFrame;
    bubbleContentImageView.frame = cellModel.contentImageViewFrame;
    self.progressView.frame = cellModel.playBtnFrame;
    bubbleContentImageView.image = cellModel.thumbnail;
    
    sendingIndicator.hidden = true;
    [sendingIndicator stopAnimating];
    if (cellModel.sendStatus == MXChatMessageSendStatusSending && cellModel.cellFromType == MXChatCellOutgoing) {
        sendingIndicator.hidden = false;
        sendingIndicator.frame = cellModel.sendingIndicatorFrame;
        [sendingIndicator startAnimating];
    }
    
    failureImageView.hidden = true;
    if (cellModel.sendStatus == MXChatMessageSendStatusFailure) {
        failureImageView.hidden = false;
        failureImageView.frame = cellModel.sendFailureFrame;
    }
    
    // 更新已读状态指示器
    [self updateReadStatusIndicator:cellModel];
}

- (void)clickPlaybtn {
    
    if (cellModel && !cellModel.isDownloading) {
        if (self.mediaPath && [MXChatFileUtil fileExistsAtPath:self.mediaPath isDirectory:NO]) {
            [self.chatCellDelegate showPlayVideoControllerWith:self.mediaPath serverPath:self.mediaServerPath];
        } else {
            __weak typeof(self) weakSelf = self;
            [cellModel startDownloadMediaCompletion:^(NSString * _Nonnull mediaPath) {
                [weakSelf.chatCellDelegate showPlayVideoControllerWith:mediaPath serverPath:weakSelf.mediaServerPath];
            }];
        }
    }
}

#pragma 点击发送失败消息 重新发送事件
- (void)tapFailImage:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重新发送吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.chatCellDelegate resendMessageInCell:self resendData:@{@"video" : self.mediaPath}];
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
- (void)updateReadStatusIndicator:(MXVideoCellModel *)cellModel {
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
