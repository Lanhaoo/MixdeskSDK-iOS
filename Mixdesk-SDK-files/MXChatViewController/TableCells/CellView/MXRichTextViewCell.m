//
//  MXRichTextViewCell.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/14.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXRichTextViewCell.h"
#import "UIView+MXLayout.h"
#import "MXChatViewConfig.h"
#import "MXImageUtil.h"
#import "MXCellModelProtocol.h"
#import "MXRichTextViewModel.h"
#import "MXWindowUtil.h"
#import "MXAssetUtil.h"
#import "MXServiceToViewInterface.h"

CGFloat internalSpace = 10;
CGFloat internalImageToTextSpace = kMXCellBubbleToTextHorizontalLargerSpacing;
CGFloat internalImageWidth = 80;

@interface MXRichTextViewCell()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *itemsView;
@property (nonatomic, strong) UIImageView *indicatorImageView;

@property (nonatomic, strong) MXRichTextViewModel *viewModel;

// 已读状态指示器
@property (nonatomic, strong) UIImageView *readStatusIndicatorView;

@end


@implementation MXRichTextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self makeConstraints];
        [self setupAction];
    }
    return self;
}

- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
    self.viewModel = model;
    [self bind:model];
    
    // 更新已读状态指示器
    [self updateReadStatusIndicator:(MXRichTextViewModel *)model];
}

//通过将 UI 于 viewModel 的响应方法绑定，使得 UI 可以响应数据的变化
- (void)bind:(MXRichTextViewModel *)viewModel {
    
    __weak typeof(self) wself = self;
    [self.viewModel setModelChanges:^(NSString *summary, NSString *iconPath, NSString *content) {
        __strong typeof (wself) sself = wself;
        
        sself.contentLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - kMXCellAvatarToBubbleSpacing - kMXCellBubbleToTextHorizontalSmallerSpacing - kMXCellBubbleMaxWidthToEdgeSpacing - kMXCellAvatarDiameter - kMXCellAvatarToHorizontalEdgeSpacing - internalSpace - internalImageToTextSpace - internalImageWidth;
        
        if (summary.length > 0) {
            sself.contentLabel.text = summary;
        } else {
            sself.contentLabel.text = [sself stripTags:content];
        }
    }];
    
    self.iconImageView.image = [MXAssetUtil imageFromBundleWithName:@"default_image"];
    [self.viewModel setIconLoaded:^(UIImage *iconImage) {
        __strong typeof (wself) sself = wself;
        if (iconImage) {
            sself.iconImageView.image = iconImage;
        }
    }];
    
    [self.viewModel setCellHeight:^CGFloat{
        return internalImageWidth + kMXCellAvatarToVerticalEdgeSpacing * 2;
    }];
    
    // 绑定完成，通知 viewModel 进行数据加载和加工
    [self.viewModel load];
}


- (NSString *)stripTags:(NSString *)str
{
    NSMutableString *html = [NSMutableString stringWithCapacity:[str length]];
    
    NSScanner *scanner = [NSScanner scannerWithString:str];
    scanner.charactersToBeSkipped = NULL;
    NSString *tempText = nil;
    
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:&tempText];
        
        if (tempText != nil)
            [html appendString:[NSString stringWithFormat:@"%@",tempText]];
        
        [scanner scanUpToString:@">" intoString:NULL];
        
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
        
        tempText = nil;
    }
    
    return html;
}

- (void)setupUI {
    [self.contentView addSubview:self.itemsView];
    self.iconImageView = [[UIImageView alloc] initWithImage:[MXChatViewConfig sharedConfig].incomingDefaultAvatarImage];
    self.indicatorImageView = [[UIImageView alloc] initWithImage:[MXAssetUtil imageFromBundleWithName:@"arrowRight"]];
    [self.itemsView addSubview:self.iconImageView];
    [self.itemsView addSubview:self.contentLabel];
    [self.itemsView addSubview:self.indicatorImageView];
    
    // 初始化已读状态指示器
    self.readStatusIndicatorView = [[UIImageView alloc] init];
    self.readStatusIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
    self.readStatusIndicatorView.hidden = YES;
    [self.contentView addSubview:self.readStatusIndicatorView];
}

- (void)makeConstraints {
    
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.itemsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *d = @{@"icon":self.iconImageView, @"label":self.contentLabel, @"indicator":self.indicatorImageView};
    NSDictionary *m = @{@"av":@(kMXCellAvatarToVerticalEdgeSpacing), @"bv":@(kMXCellBubbleToTextVerticalSpacing), @"al":@(kMXCellAvatarToBubbleSpacing), @"br":@(kMXCellBubbleMaxWidthToEdgeSpacing), @"ad":@(kMXCellAvatarDiameter), @"id":@(internalImageWidth), @"is":@(internalSpace), @"iis":@(internalImageToTextSpace), @"bts":@(kMXCellBubbleToTextHorizontalLargerSpacing), @"btvs":@(kMXCellBubbleToTextVerticalSpacing)};
    
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[icon(id)]-is-[label]-10-[indicator(13)]-10-|" options:0 metrics:m views:d]];
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[icon(id)]-0-|" options:0 metrics:m views:d]];
    [self.itemsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[label]-|" options:0 metrics:m views:d]];
    [self.itemsView addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorImageView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self.itemsView attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]];
    
    d = @{@"items":self.itemsView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-av-[items]-br-|" options:0 metrics:m views:d]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-av-[items]-av-|" options:0 metrics:m views:d]];
}

- (void)setupAction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openURL)];
    [self.itemsView addGestureRecognizer:tap];
}

- (void)openURL {
    [self.viewModel openFrom:[MXWindowUtil topController]];
}

#pragma mark -

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textAlignment = NSTextAlignmentNatural;
        _contentLabel.textColor = [MXChatViewConfig sharedConfig].incomingMsgTextColor;
        _contentLabel.font = [UIFont systemFontOfSize:15];

    }
    return _contentLabel;
}

- (UIView *)itemsView {
    if (!_itemsView) {
        _itemsView = [UIView new];
        _itemsView.backgroundColor = [MXChatViewConfig sharedConfig].incomingBubbleColor;
        _itemsView.layer.cornerRadius = 4;
        _itemsView.layer.masksToBounds = YES;
        _itemsView.layer.borderColor = [UIColor mx_colorWithHexString:silver].CGColor;
        _itemsView.layer.borderWidth = 0.5;
    }
    return _itemsView;
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
- (void)updateReadStatusIndicator:(MXRichTextViewModel *)cellModel {
    self.readStatusIndicatorView.hidden = YES;

    return;
    
    // 移除之前的约束
    [self.readStatusIndicatorView removeFromSuperview];
    
    // 只有发送消息且启用了状态显示才显示指示器
    if (![MXServiceToViewInterface isAgentToClientMsgStatus] || cellModel.readStatus == nil) {
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
        self.readStatusIndicatorView.image = statusImage;
        [self.contentView addSubview:self.readStatusIndicatorView];
        
        // 使用frame设置位置（基于readStatusIndicatorFrame）
        self.readStatusIndicatorView.frame = cellModel.readStatusIndicatorFrame;
        self.readStatusIndicatorView.hidden = NO;
        self.readStatusIndicatorView.backgroundColor = [UIColor clearColor];
        [self.contentView bringSubviewToFront:self.readStatusIndicatorView];
    }
}

@end
