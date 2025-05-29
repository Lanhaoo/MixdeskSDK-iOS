//
//  MXSplitLineCellModel.h
//  MXEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/10/20.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXSplitLineCellModel : NSObject <MXCellModelProtocol>

@property (nonatomic, readonly, assign) CGRect labelFrame;
@property (nonatomic, readonly, assign) CGRect leftLineFrame;
@property (nonatomic, readonly, assign) CGRect rightLineFrame;

- (MXSplitLineCellModel *)initCellModelWithCellWidth:(CGFloat)cellWidth withConversionDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
