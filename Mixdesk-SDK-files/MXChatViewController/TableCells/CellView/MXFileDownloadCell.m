//
//  MXFileDownloadCell.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/4/6.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXFileDownloadCell.h"
#import "UIView+MXLayout.h"
#import "MXFileDownloadCellModel.h"
#import "MXChatViewConfig.h"
#import "MXImageUtil.h"
#import "MXChatViewConfig.h"
#import "MXAssetUtil.h"
#import "MXBundleUtil.h"
#import "MXWindowUtil.h"
#import "MXServiceToViewInterface.h"

@interface MXFileDownloadCell()<UIActionSheetDelegate>

@property (nonatomic, strong) MXFileDownloadCellModel *viewModel;

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, strong) UILabel *fileDetailLabel;
@property (nonatomic, strong) UIProgressView *downloadProgressBar;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *itemsView;
@property (nonatomic, strong) UITapGestureRecognizer *tagGesture;

@end

@implementation MXFileDownloadCell {
    UIImageView *readStatusIndicatorView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.itemsView addSubview:self.icon];
        [self.itemsView addSubview:self.fileNameLabel];
        [self.itemsView addSubview:self.fileDetailLabel];
        [self.itemsView addSubview:self.actionButton];
        [self.itemsView addSubview:self.downloadProgressBar];
        
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.itemsView];
        
        //初始化已读状态指示器
        readStatusIndicatorView = [[UIImageView alloc] init];
        readStatusIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
        readStatusIndicatorView.hidden = YES;
        [self.contentView addSubview:readStatusIndicatorView];
        
        [self updateUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateUI];
}

- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
    self.viewModel = model;
    
    [self updateUI];
    
    //user action callbacks
    __weak typeof (self)wself = self;
    
    [self.viewModel setNeedsToUpdateUI:^{
        __strong typeof (wself)sself = wself;
        [sself updateUI];
    }];
    
    [self.viewModel setAvatarLoaded:^(UIImage *image) {
        __strong typeof (wself)sself = wself;
        [sself.avatarImageView setImage:image];
    }];
    
    [self.viewModel setCellHeight:^CGFloat{
        __strong typeof (wself)sself = wself;
        [sself updateUI];
        return sself.viewHeight;
    }];
}

#pragma mark -

- (void)updateUI {
    MXFileDownloadStatus status = self.viewModel.fileDownloadStatus;
    
    //update UI contents according to status
    
    self.actionButton.hidden = (status == MXFileDownloadStatusDownloadComplete);
    self.downloadProgressBar.hidden = (status != MXFileDownloadStatusDownloading);
    
    CGFloat rightEdgeSpace = 5; //由于图片边界的原因，调整一下有图片和没有图片右边的距离，这样看起来协调一点.
    
    switch (status) {
        case MXFileDownloadStatusNotDownloaded: {
            [self.actionButton setImage:[MXAssetUtil fileDonwload] forState:UIControlStateNormal];
            if (self.viewModel.isExpired) {
                [self.fileDetailLabel setText:[NSString stringWithFormat:@"%@ ∙ %@",self.viewModel.fileSize, [MXBundleUtil localizedStringForKey:@"file_download_file_is_expired"]]];
            } else {
                [self.fileDetailLabel setText:[NSString stringWithFormat:[MXBundleUtil localizedStringForKey:@"file_download_ %@ ∙ %@overdue"], self.viewModel.fileSize, self.viewModel.timeBeforeExpire]];
            }
        }
        break;
        case MXFileDownloadStatusDownloading: {
            [self.actionButton setImage:[MXAssetUtil fileCancel] forState:UIControlStateNormal];
            self.downloadProgressBar.progress = 0;//表示开始下载
            [self.fileDetailLabel setText:[MXBundleUtil localizedStringForKey:@"file_download_downloading"]];
        }
        break;
        case MXFileDownloadStatusDownloadComplete: {
            [self.actionButton setImage:nil forState:UIControlStateNormal];
            [self.fileDetailLabel setText:[MXBundleUtil localizedStringForKey:@"file_download_complete"]];
            rightEdgeSpace = kMXCellBubbleToTextHorizontalLargerSpacing;
        }
        break;
    }
    
    [self.fileNameLabel setText:self.viewModel.fileName];
    [self.fileNameLabel sizeToFit];
    [self.fileDetailLabel sizeToFit];
    
    if (self.viewModel.avartarImage) {
        self.avatarImageView.image = self.viewModel.avartarImage;
    }
    
    //layout
    
    [self.avatarImageView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMXCellAvatarToVerticalEdgeSpacing, kMXCellAvatarToHorizontalEdgeSpacing)];
    [self.itemsView align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.avatarImageView.viewRightEdge + kMXCellAvatarToBubbleSpacing, self.avatarImageView.viewY)];
    
    [self.icon align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(kMXCellBubbleToTextHorizontalLargerSpacing, kMXCellBubbleToTextVerticalSpacing)];
    [self.fileNameLabel align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.icon.viewRightEdge + 5, self.icon.viewY)];
    
    [self.fileDetailLabel align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(self.fileNameLabel.viewX, self.fileNameLabel.viewBottomEdge + 5)];
    
    if (self.downloadProgressBar.isHidden) {
        self.downloadProgressBar.viewHeight = 0;
    } else {
        self.downloadProgressBar.viewHeight = 5;
    }
    
    CGFloat maxMiddleRightEdge = self.viewWidth - self.avatarImageView.viewRightEdge - !self.actionButton.isHidden * self.actionButton.viewWidth - kMXCellAvatarToVerticalEdgeSpacing - kMXCellBubbleMaxWidthToEdgeSpacing;
    CGFloat middlePartRightEdge = MIN(MAX(self.fileNameLabel.viewRightEdge, self.fileDetailLabel.viewRightEdge), maxMiddleRightEdge);
    self.fileNameLabel.viewWidth = maxMiddleRightEdge - self.fileNameLabel.viewX; // 防止文件名过长
    self.fileDetailLabel.viewWidth = maxMiddleRightEdge - self.fileDetailLabel.viewX;
    
    [self.downloadProgressBar align:ViewAlignmentTopLeft relativeToPoint:CGPointMake([MXChatViewConfig sharedConfig].bubbleImageStretchInsets.left, self.fileDetailLabel.viewBottomEdge + kMXCellBubbleToTextHorizontalSmallerSpacing)];
    
    [self.actionButton align:ViewAlignmentTopLeft relativeToPoint:CGPointMake(middlePartRightEdge + 5, kMXCellBubbleToTextVerticalSpacing)];
    
    self.itemsView.viewWidth = middlePartRightEdge + (5 + self.actionButton.viewWidth) * !self.actionButton.isHidden + rightEdgeSpace;
    
    self.downloadProgressBar.viewWidth = self.itemsView.viewWidth - [MXChatViewConfig sharedConfig].bubbleImageStretchInsets.left - [MXChatViewConfig sharedConfig].bubbleImageStretchInsets.right;
    
    self.itemsView.viewHeight = self.downloadProgressBar.viewBottomEdge;

    self.contentView.viewHeight = self.itemsView.viewBottomEdge + kMXCellAvatarToVerticalEdgeSpacing;
    self.viewHeight = self.contentView.viewHeight;
    
    // 更新已读状态指示器
    [self updateReadStatusIndicator:self.viewModel];
}

///点击状态按钮和整个cell都会触发此方法
- (void)actionForActionButton:(id)sender {
    switch (self.viewModel.fileDownloadStatus) {
        case MXFileDownloadStatusNotDownloaded: {
            __weak typeof (self)wself = self;
            [self.viewModel startDownloadWitchProcess:^(CGFloat process) {
                __strong typeof (wself)sself = wself;
                if (process >= 0 && process < 100) {
                    [sself.downloadProgressBar setProgress:process];
                } else if (process == 100) {
                    [sself updateUI];
                    [self showActionSheet];
                } else {
                    [sself updateUI];
                }
            }];
        }
        break;
        case MXFileDownloadStatusDownloading: {
            if ([sender isKindOfClass:[UIButton class]]) { //取消操作只有在点击取消按钮时响应
                [self.viewModel cancelDownload];
            }
        }
        break;
        case MXFileDownloadStatusDownloadComplete: {
            [self showActionSheet];
        }
        break;
    }
}

- (void)showActionSheet {
    [self.window endEditing:YES];
    UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:[MXBundleUtil localizedStringForKey:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:[MXBundleUtil localizedStringForKey:@"mx_display_preview"],[MXBundleUtil localizedStringForKey:@"mx_open_file"], nil];

    as.delegate = self;
    [as showInView:self];
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.viewModel previewFileFromController:[MXWindowUtil topController]];
    } else if (buttonIndex == 1) {
        [self.viewModel openFile:self];
    }
}

#pragma mark - lazy load

- (UIImageView *)itemsView {
    if (!_itemsView) {
        _itemsView = [UIImageView new];
        _itemsView.userInteractionEnabled = true;
        UIImage *bubbleImage = [MXChatViewConfig sharedConfig].incomingBubbleImage;
        if ([MXChatViewConfig sharedConfig].incomingBubbleColor) {
            bubbleImage = [MXImageUtil convertImageColorWithImage:bubbleImage toColor:[MXChatViewConfig sharedConfig].incomingBubbleColor];
        }
        bubbleImage = [bubbleImage resizableImageWithCapInsets:[MXChatViewConfig sharedConfig].bubbleImageStretchInsets];
        _itemsView.image = bubbleImage;
        [_itemsView addGestureRecognizer:self.tagGesture];
    }
    return _itemsView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[MXAssetUtil fileIcon]];
        _icon.viewSize = CGSizeMake(kMXCellAvatarDiameter, kMXCellAvatarDiameter);
    }
    return _icon;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton new];
        _actionButton.viewSize = CGSizeMake(35, 35);
        [_actionButton addTarget:self action:@selector(actionForActionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [UILabel new];
        _fileNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _fileNameLabel;
}

- (UILabel *)fileDetailLabel {
    if (!_fileDetailLabel) {
        _fileDetailLabel = [UILabel new];
        _fileDetailLabel.font = [UIFont systemFontOfSize:12];
        _fileDetailLabel.textColor = [UIColor lightGrayColor];
        _fileDetailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _fileDetailLabel;
}

- (UIProgressView *)downloadProgressBar {
    if (!_downloadProgressBar) {
        _downloadProgressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    }
    
    return _downloadProgressBar;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.viewSize = CGSizeMake(kMXCellAvatarDiameter, kMXCellAvatarDiameter);
        _avatarImageView.image = [MXChatViewConfig sharedConfig].incomingDefaultAvatarImage;
        if ([MXChatViewConfig sharedConfig].enableRoundAvatar) {
            _avatarImageView.layer.masksToBounds = YES;
            _avatarImageView.layer.cornerRadius = _avatarImageView.viewSize.width/2;
        }
    }
    return _avatarImageView;
}

- (UITapGestureRecognizer *)tagGesture {
    if (!_tagGesture) {
        _tagGesture = [UITapGestureRecognizer new];
        [_tagGesture addTarget:self action:@selector(actionForActionButton:)];
    }
    return _tagGesture;
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
- (void)updateReadStatusIndicator:(MXFileDownloadCellModel *)cellModel {
    readStatusIndicatorView.hidden = YES;
    
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
        readStatusIndicatorView.image = statusImage;
        readStatusIndicatorView.frame = cellModel.readStatusIndicatorFrame;
        readStatusIndicatorView.hidden = NO;
        readStatusIndicatorView.backgroundColor = [UIColor clearColor];
        [self.contentView bringSubviewToFront:readStatusIndicatorView];
    }
}

@end
