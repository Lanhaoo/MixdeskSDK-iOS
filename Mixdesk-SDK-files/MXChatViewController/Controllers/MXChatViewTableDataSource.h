//
//  MXChatViewTableDataSource.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXChatViewService.h"
#import <UIKit/UIKit.h>
#import "MXChatBaseCell.h"

/**
 * @brief 客服聊天界面中的UITableView的datasource
 */
@interface MXChatViewTableDataSource : NSObject <UITableViewDataSource>

//- (instancetype)initWithTableView:(UITableView *)tableView  chatViewService:(MXChatViewService *)chatService;
- (instancetype)initWithChatViewService:(MXChatViewService *)chatService;
/**
 *  ChatCell的代理
 */
@property (nonatomic, weak) id<MXChatCellDelegate> chatCellDelegate;

@end
