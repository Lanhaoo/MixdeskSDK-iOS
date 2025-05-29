//
//  MXRadioGroup.m
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2020/5/26.
//  Copyright © 2020 Mixdesk. All rights reserved.
//

#import "MXRadioGroup.h"

@implementation MXRadioGroup

-(id)initWithFrame:(CGRect)frame WithCheckBtns:(NSArray *)checkBtns
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _selectTextArr=[[NSMutableArray alloc] init];
        _selectValueArr=[[NSMutableArray alloc] init];
        for (id checkBtn in checkBtns) {
            [self addSubview:checkBtn];
        }
        [self commonInit];
    }
    return self;
}
-(void)commonInit
{
    for (UIView *checkBtn in self.subviews) {
        if ([checkBtn isKindOfClass:[MXRadioButton class]]) {
            if (((MXRadioButton*)checkBtn).selectedAll) {
                [(MXRadioButton*)checkBtn addTarget:self action:@selector(selectedAllCheckBox:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [(MXRadioButton*)checkBtn addTarget:self action:@selector(checkboxBtnChecked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}
-(void)checkboxBtnChecked:(MXRadioButton *)sender
{
    if (self.isCheck) {
        sender.selected=!sender.selected;
        if (sender.selected) {
            [_selectTextArr addObject:((MXRadioButton *)sender).text];
            [_selectValueArr addObject:((MXRadioButton *)sender).value];
        }else{
            for (id checkBtn in self.subviews) {
                if ([checkBtn isKindOfClass:[MXRadioButton class]]) {
                    if (((MXRadioButton *)checkBtn).selectedAll) {
                        [(MXRadioButton *)checkBtn setSelected:NO];
                    }
                }
            }
            [_selectTextArr removeObject:((MXRadioButton *)sender).text];
            [_selectValueArr removeObject:((MXRadioButton *)sender).value];
        }
    }else{
        for (id checkBtn in self.subviews) {
            if ([checkBtn isKindOfClass:[MXRadioButton class]]) {
                [(MXRadioButton *)checkBtn setSelected:NO];
            }
        }
        sender.selected=YES;
        self.selectText = ((MXRadioButton *)sender).text;
        self.selectValue = ((MXRadioButton *)sender).value;
    }
}
-(void)selectedAllCheckBox:(MXRadioButton *)sender
{
    sender.selected=!sender.selected;
    [_selectTextArr removeAllObjects];
    [_selectValueArr removeAllObjects];
    for (id checkBtn in self.subviews) {
        if ([checkBtn isKindOfClass:[MXRadioButton class]]) {
            if (!((MXRadioButton *)checkBtn).selectedAll) {
                [(MXRadioButton *)checkBtn setSelected:sender.selected];
                if (((MXRadioButton *)checkBtn).selected) {
                    [_selectTextArr addObject:((MXRadioButton *)checkBtn).text];
                    [_selectValueArr addObject:((MXRadioButton *)checkBtn).value];
                }
            }
        }
    }
}
@end
