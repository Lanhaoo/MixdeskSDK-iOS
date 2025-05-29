//
//  MXPageView.h
//  123
//
//  Created by shunxingzhang on 2022/12/26.
//  Copyright © 2022 shunxingzhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXPageDataModel.h"
#import "MXPageScrollItemView.h"
#import "MXPageScrollMenuView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MXPageViewSelectedBlock)(NSString *content);

static CGFloat const kMXPageLineHeight = 1.0;
static CGFloat const kMXPageScrollMenuViewHeight = 30.0;
static CGFloat const kMXPageBottomButtonHeight = 30.0;

@interface MXPageView : UIView

/**
 * 生成 PageController
 *
 * @param frame react
 * @param list 数据源
 * @param size 每页显示的最多条数，超过就翻页
 * @param block 点击item内容的回调
 */
- (instancetype)initWithFrame:(CGRect)frame
                      dataArr:(NSArray<MXPageDataModel *> *)list
                    pageMaxSize:(int)size
                    block:(MXPageViewSelectedBlock)block;

- (void)updateViewFrameWith:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
