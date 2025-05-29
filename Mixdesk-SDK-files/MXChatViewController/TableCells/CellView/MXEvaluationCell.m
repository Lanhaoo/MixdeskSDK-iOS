//
//  MXEvaluationCell.m
//  MXChatViewControllerDemo
//
//  Created by ijinmao on 16/1/19.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "MXEvaluationCell.h"
#import "MXAssetUtil.h"
#import "MXBundleUtil.h"

static CGFloat const kMXEvaluationCellVerticalSpacing = 12.0;
static CGFloat const kMXEvaluationCellHorizontalSpacing = 12.0;
static CGFloat const kMXEvaluationCellTextWidth = 80.0;
static CGFloat const kMXEvaluationCellTextHeight = 30.0;

@implementation MXEvaluationCell {
    UIImageView *levelImageView;
    UILabel *levelLabel;
    UIView *bottomLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //cell 的配置
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //评价的头像
        levelImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:levelImageView];
        //评价文字
        levelLabel = [[UILabel alloc] init];
        levelLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        levelLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:levelLabel];
        //画上下两条线
        bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
        [self.contentView addSubview:bottomLine];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    UIImage *defaultImage = [MXAssetUtil getEvaluationImageWithLevel:0];
    levelImageView.frame = CGRectMake(0, frame.size.height/2-defaultImage.size.height/2, defaultImage.size.width, defaultImage.size.height);
    levelLabel.frame = CGRectMake(levelImageView.frame.origin.x+levelImageView.frame.size.width+kMXEvaluationCellHorizontalSpacing, frame.size.height/2-kMXEvaluationCellTextHeight/2, kMXEvaluationCellTextWidth, kMXEvaluationCellTextHeight);
    bottomLine.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 0.5);
}

- (void)setLevel:(NSInteger)level {
    levelImageView.image = [MXAssetUtil getEvaluationImageWithLevel:level];
    switch (level) {
        case 0:
        {
            levelLabel.text = [MXBundleUtil localizedStringForKey:@"mx_evaluation_bad"];
            break;
        }
        case 1:
        {
            levelLabel.text = [MXBundleUtil localizedStringForKey:@"mx_evaluation_middle"];
            break;
        }
        case 2:
        {
            levelLabel.text = [MXBundleUtil localizedStringForKey:@"mx_evaluation_good"];
            break;
        }
        default:
            break;
    }
}

+ (CGFloat)getCellHeight {
    CGFloat cellHeight = 0;
    cellHeight += kMXEvaluationCellVerticalSpacing;
    UIImage *defaultImage = [MXAssetUtil getEvaluationImageWithLevel:0];
    cellHeight += defaultImage.size.height;
    cellHeight += kMXEvaluationCellVerticalSpacing;
    cellHeight += 1;
    return cellHeight;
}

- (void)hideBottomLine {
    bottomLine.hidden = true;
}

@end
