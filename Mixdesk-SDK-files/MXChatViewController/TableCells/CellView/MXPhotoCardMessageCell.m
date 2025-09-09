//
//  MXPhotoCardMessageCell.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/7/9.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXPhotoCardMessageCell.h"
#import "MXPhotoCardCellModel.h"
#import "MXChatViewConfig.h"
#import "MXImageUtil.h"
#import "MXServiceToViewInterface.h"

@implementation MXPhotoCardMessageCell {
    UIImageView *avatarImageView;
    UIView *bubbleView;
    UIImageView *bubbleContentImageView;
    UIActivityIndicatorView *loadingIndicator;
    MXPhotoCardCellModel *cellModel;
    
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
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleTapped)];
        [bubbleView addGestureRecognizer:tapGesture];
        
        [self.contentView addSubview:bubbleView];
        
        //初始化contentImageView
        bubbleContentImageView = [[UIImageView alloc] init];
        [bubbleView addSubview:bubbleContentImageView];
        //初始化加载数据的indicator
        loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.hidden = YES;
        [bubbleView addSubview:loadingIndicator];
        
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
    if (![model isKindOfClass:[MXPhotoCardCellModel class]]) {
        NSAssert(NO, @"传给MXPhotoCardMessageCell的Model类型不正确");
        return ;
    }
    cellModel = (MXPhotoCardCellModel *)model;

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
    
    //消息图片
    loadingIndicator.frame = cellModel.loadingIndicatorFrame;
    if (cellModel.image) {
        bubbleContentImageView.image = cellModel.image;
        loadingIndicator.hidden = true;
        [loadingIndicator stopAnimating];
    } else {
        bubbleContentImageView.image = nil;
        loadingIndicator.hidden = false;
        [loadingIndicator startAnimating];
    }
    
    // 更新已读状态指示器
    [self updateReadStatusIndicator:cellModel];
}

#pragma 单击气泡
- (void)bubbleTapped {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cellModel.targetUrl]];
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
- (void)updateReadStatusIndicator:(MXPhotoCardCellModel *)cellModel {
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
