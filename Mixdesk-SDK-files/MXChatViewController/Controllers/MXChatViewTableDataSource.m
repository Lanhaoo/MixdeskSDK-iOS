//
//  MXChatViewTableDataSource.m
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/28.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import "MXChatViewTableDataSource.h"
#import "MXChatBaseCell.h"
#import "MXCellModelProtocol.h"

@interface MXChatViewTableDataSource()

@property (nonatomic, weak) MXChatViewService *chatViewService;

@end

@implementation MXChatViewTableDataSource {
}

- (instancetype)initWithChatViewService:(MXChatViewService *)chatService {
    if (self = [super init]) {
        self.chatViewService = chatService;
    }
    return self;
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.chatViewService.cellModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MXCellModelProtocol> cellModel = [self.chatViewService.cellModels objectAtIndex:indexPath.row];
    NSString *cellModelName = NSStringFromClass([cellModel class]);
//    NSString *messageId = [cellModel getCellMessageId]?:NSStringFromClass([cellModel class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellModelName];
    if (!cell){
        cell = [cellModel getCellWithReuseIdentifier:cellModelName];
        MXChatBaseCell *chatCell = (MXChatBaseCell*)cell;
        chatCell.chatCellDelegate = self.chatCellDelegate;
    }
    if (![cell isKindOfClass:[MXChatBaseCell class]]) {
        NSAssert(NO, @"ChatTableDataSource的cellForRow中，没有返回正确的cell类型");
        return cell;
    }
    //xlp 富文本时返回的信息是  cell类型是  MXBotWebViewBubbleAnswerCell  model类型是 MXBotWebViewBubbleAnswerCellModel
    [(MXChatBaseCell*)cell updateCellWithCellModel:cellModel];
    return cell;
}




@end
