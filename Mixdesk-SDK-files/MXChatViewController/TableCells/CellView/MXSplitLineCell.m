//
//  MXSplitLineCell.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/20.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXSplitLineCell.h"
#import <Foundation/Foundation.h>
#import "MXSplitLineCellModel.h"
#import "MXDateFormatterUtil.h"
#import "UIColor+MXHex.h"

@implementation MXSplitLineCell {
    UILabel *_lable;
    UIView *_leftLine;
    UIView *_rightLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *lable = [[UILabel alloc] init];
        lable.font = [UIFont boldSystemFontOfSize:14];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _lable = lable;
        [self.contentView addSubview:_lable];
        
        UIView *leftLine = [UIView new];
        leftLine.backgroundColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _leftLine = leftLine;
        [self.contentView addSubview:_leftLine];
        
        UIView *rightLine = [UIView new];
        rightLine.backgroundColor = [UIColor colorWithRed:242/255 green:242/255 blue:247/255 alpha:0.2];
        _rightLine = rightLine;
        [self.contentView addSubview:_rightLine];
        
    }
    return self;
}

#pragma MXChatCellProtocol
- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model {
    if (![model isKindOfClass:[MXSplitLineCellModel class]]) {
        NSAssert(NO, @"传给MXEventMessageCell的Model类型不正确");
        return ;
    }
    MXSplitLineCellModel *cellModel = (MXSplitLineCellModel *)model;
    _lable.frame = cellModel.labelFrame;
    _leftLine.frame = cellModel.leftLineFrame;
    _rightLine.frame = cellModel.rightLineFrame;
    _lable.text = [[MXDateFormatterUtil sharedFormatter] mixdeskSplitLineDateForDate:cellModel.getCellDate];
}

@end

