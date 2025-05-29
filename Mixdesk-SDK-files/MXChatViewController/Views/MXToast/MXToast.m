#import "MXToast.h"
#import <UIKit/UIKit.h>

// 设置Toast样式的常量
static const float kMXToastMaxWidth = 0.8; // 窗口宽度的80%
static const float kMXToastFontSize = 16; // 增大字体以提高可见性
static const float kMXToastHorizontalSpacing = 12.0; // 增加水平间距
static const float kMXToastVerticalSpacing = 8.0; // 增加垂直间距

@implementation MXToast

+ (void)showToast:(NSString*)message duration:(NSTimeInterval)interval window:(UIView*)window
{
    // 检查参数有效性
    if (!window || !message || message.length == 0) {
        return;
    }
    
    // 确保在主线程执行UI操作
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取窗口尺寸
        CGSize windowSize = window.frame.size;
        
        // 创建标签用于显示文本
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:kMXToastFontSize];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = message;
        
        // 计算文本尺寸
        CGSize maxSizeTitle = CGSizeMake(windowSize.width * kMXToastMaxWidth, windowSize.height);
        CGSize expectedSizeTitle;
        
        // 使用boundingRectWithSize计算文本尺寸
        NSDictionary *attributes = @{NSFontAttributeName: titleLabel.font};
        expectedSizeTitle = [message boundingRectWithSize:maxSizeTitle
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:attributes
                                                 context:nil].size;
        
        // 设置标签框架
        titleLabel.frame = CGRectMake(kMXToastHorizontalSpacing, 
                                     kMXToastVerticalSpacing, 
                                     expectedSizeTitle.width + 4, 
                                     expectedSizeTitle.height);
        
        // 创建容器视图
        UIView *toastView = [[UIView alloc] init];
        // 将位置移到视图中央
        toastView.frame = CGRectMake((windowSize.width - titleLabel.frame.size.width) / 2 - kMXToastHorizontalSpacing,
                               windowSize.height * 0.5 - titleLabel.frame.size.height * 2, // 位置偏上一些
                               titleLabel.frame.size.width + kMXToastHorizontalSpacing * 2,
                               titleLabel.frame.size.height + kMXToastVerticalSpacing * 2);
        
        // 设置视图样式
        toastView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9]; // 更暗和更不透明
        toastView.alpha = 0;
        toastView.layer.cornerRadius = 10.0; // 更大的圆角
        toastView.layer.masksToBounds = YES;
        
        // 添加标签到容器视图
        [toastView addSubview:titleLabel];
        
        // 确保视图在最上层
        toastView.layer.zPosition = 1000;
        [window addSubview:toastView];
        
        // 显示动画
        [UIView animateWithDuration:0.3 animations:^{
            toastView.alpha = 1;
        } completion:^(BOOL finished) {
            if (interval > 0) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // 隐藏动画
                    [UIView animateWithDuration:interval animations:^{
                        toastView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [toastView removeFromSuperview];
                    }];
                });
            }
        }];
    });
}

@end
