//
//  MXSplitLineCellModel.m
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/20.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXSplitLineCellModel.h"
#import "MXSplitLineCell.h"

static CGFloat const kMXSplitLineCellSpacing = 20.0;
static CGFloat const kMXSplitLineCellHeight = 40.0;
static CGFloat const kMXSplitLineCellLableHeight = 20.0;
static CGFloat const kMXSplitLineCellLableWidth = 150.0;
@interface MXSplitLineCellModel()

/**
 * @brief cell的宽度
 */
@property (nonatomic, readwrite, assign) CGFloat cellWidth;
@property (nonatomic, readwrite, assign) CGRect labelFrame;
@property (nonatomic, readwrite, assign) CGRect leftLineFrame;
@property (nonatomic, readwrite, assign) CGRect rightLineFrame;
@property (nonatomic, readwrite, copy) NSDate *currentDate;

@end

@implementation MXSplitLineCellModel

- (MXSplitLineCellModel *)initCellModelWithCellWidth:(CGFloat)cellWidth withConversionDate:(NSDate *)date {
    if (self = [super init]) {
        self.cellWidth = cellWidth;
        self.currentDate = date;
        self.labelFrame = CGRectMake(cellWidth/2.0 - kMXSplitLineCellLableWidth/2.0, (kMXSplitLineCellHeight - kMXSplitLineCellLableHeight)/2.0 - 3, kMXSplitLineCellLableWidth, kMXSplitLineCellLableHeight);
        self.leftLineFrame = CGRectMake(kMXSplitLineCellSpacing, kMXSplitLineCellHeight/2.0, CGRectGetMinX(self.labelFrame) - kMXSplitLineCellSpacing, 0.5);
        self.rightLineFrame = CGRectMake(CGRectGetMaxX(self.labelFrame), CGRectGetMinY(self.leftLineFrame), cellWidth - kMXSplitLineCellSpacing - CGRectGetMaxX(self.labelFrame), 0.5);
    }
    return self;
}


#pragma MXCellModelProtocol
- (NSDate *)getCellDate {
    return self.currentDate;
}

- (CGFloat)getCellHeight {
    return kMXSplitLineCellHeight;
}

- (NSString *)getCellMessageId {
    return @"";
}

- (NSString *)getMessageConversionId {
    return @"";
}

- (NSString *)getMessageReadStatus {
  return @"";
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[MXSplitLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];;
}

- (BOOL)isServiceRelatedCell {
    return false;
}

- (void)updateCellFrameWithCellWidth:(CGFloat)cellWidth {
    self.cellWidth = cellWidth;
    
    self.labelFrame = CGRectMake(cellWidth/2.0 - kMXSplitLineCellLableWidth/2.0, (kMXSplitLineCellHeight - kMXSplitLineCellLableHeight)/2.0, kMXSplitLineCellLableWidth, kMXSplitLineCellLableHeight);
    self.leftLineFrame = CGRectMake(kMXSplitLineCellSpacing, kMXSplitLineCellHeight/2.0, CGRectGetMinX(self.labelFrame) - kMXSplitLineCellSpacing, 1);
    self.rightLineFrame = CGRectMake(CGRectGetMaxX(self.labelFrame), CGRectGetMinY(self.leftLineFrame), cellWidth - kMXSplitLineCellSpacing - CGRectGetMaxX(self.labelFrame), 1);
}

@end
