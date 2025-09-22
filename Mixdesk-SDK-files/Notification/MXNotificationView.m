
#import "MXNotificationView.h"
#import "MXAssetUtil.h"
#import "MXServiceToViewInterface.h"
#ifndef INCLUDE_MIXDESK_SDK
#import "UIImageView+WebCache.h"
#endif

static CGFloat const kMXNotificationViewContentPadding = 10.0;
static CGFloat const kMXNotificationViewContentSpace = 5.0;
static CGFloat const kMXNotificationViewAvatarH = 20.0;
static CGFloat const kMXNotificationViewNameW = 200.0;

@interface MXNotificationView()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation MXNotificationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 5.0;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
        self.layer.shadowPath = path.CGPath;
        self.layer.shadowOpacity = 1.0;
        [self configSubview];
    }
    return self;
}


- (void)configSubview {
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.contentLabel];
}

-(void)configViewWithSenderName:(NSString *)name senderAvatarUrl:(NSString *)avatar sendContent:(NSString *)content {
    self.nameLabel.text = name;
    self.contentLabel.text = content;
    self.avatarImageView.image = [MXChatViewConfig sharedConfig].incomingDefaultAvatarImage;
    
    //这里使用Mixdesk接口下载多媒体消息的图片，开发者也可以替换成自己的图片缓存策略
#ifdef INCLUDE_MIXDESK_SDK
    __weak typeof(self) weakSelf = self;
    [MXServiceToViewInterface downloadMediaWithUrlString:avatar progress:^(float progress) {
    } completion:^(NSData *mediaData, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (mediaData && !error) {
            UIImage *image = [UIImage imageWithData:mediaData];
            strongSelf.avatarImageView.image = image;
        }
    }];
#else
    //非MixdeskSDK用户，使用了SDWebImage来做图片缓存
    __weak typeof(self) weakSelf = self;
    [tempImageView sd_setImageWithURL:[NSURL URLWithString:message.imagePath] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (image) {
            strongSelf.avatarImageView.image = image;
        }
    }];
#endif
}


- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMXNotificationViewContentPadding, kMXNotificationViewContentPadding, kMXNotificationViewAvatarH, kMXNotificationViewAvatarH)];
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = kMXNotificationViewAvatarH/2;
        _avatarImageView.image = [MXAssetUtil imageFromBundleWithName:@"MXIcon"];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + kMXNotificationViewContentSpace, CGRectGetMinY(self.avatarImageView.frame), kMXNotificationViewNameW, CGRectGetHeight(self.avatarImageView.frame))];
        _nameLabel.textColor = [UIColor colorWithRed:111/255.0 green:117/255.0 blue:146/255.0 alpha:1.0];
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.text = @"客服名称";
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMXNotificationViewContentPadding, CGRectGetMaxY(self.nameLabel.frame) + kMXNotificationViewContentSpace, CGRectGetWidth(self.frame) - 2 * kMXNotificationViewContentPadding, kMXNotificationViewHeight - CGRectGetMaxY(self.nameLabel.frame) - kMXNotificationViewContentSpace - kMXNotificationViewContentPadding)];
        _contentLabel.font = [UIFont systemFontOfSize:14.0];
        _contentLabel.numberOfLines = 2;
        _contentLabel.text = @"发送内容";
    }
    return _contentLabel;
}

@end
