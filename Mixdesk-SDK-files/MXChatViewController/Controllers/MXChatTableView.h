//
//  MXChatTableView.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/30.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXChatViewService.h"

@protocol MXChatTableViewDelegate <NSObject>

/** 点击 */
- (void)didTapChatTableView:(UITableView *)tableView;

@end

@interface MXChatTableView : UITableView


@property (nonatomic, weak) id<MXChatTableViewDelegate> chatTableViewDelegate;


/** 更新indexPath的cell */
- (void)updateTableViewAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollToCellIndex:(NSInteger)index;

- (BOOL)isTableViewScrolledToBottom;

@end
