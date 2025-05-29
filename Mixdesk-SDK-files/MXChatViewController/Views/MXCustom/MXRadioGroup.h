//
//  MXRadioGroup.h
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXRadioButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXRadioGroup : UIView

@property (nonatomic, copy) NSString *selectText;
@property (nonatomic, copy) NSString *selectValue;
@property (nonatomic, strong) NSMutableArray *selectTextArr;
@property (nonatomic, strong) NSMutableArray *selectValueArr;
@property (nonatomic,assign) BOOL isCheck;

- (id)initWithFrame:(CGRect)frame WithCheckBtns:(NSArray*)checkBtns;

@end

NS_ASSUME_NONNULL_END
