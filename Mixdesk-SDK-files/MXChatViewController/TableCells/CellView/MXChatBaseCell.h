//
//  MXChatBaseCell.h
//  MixdeskSDK
//
//  Created by ijinmao on 15/10/29.
//  Copyright © 2015年 Mixdesk Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXNamespacedDependencies.h"

@protocol MXCellModelProtocol;

/**
 * 所有的集成的cell需要满足的协议
 */
@protocol MXChatCellProtocol <NSObject>

/**
 * 根据cellModel中的数据，来更新cell的界面
 * @param cellModel cell的数据
 */
- (void)updateCellWithCellModel:(id<MXCellModelProtocol>)model;

@end

/**
 * 所有cell的代理方法
 */
@protocol MXChatCellDelegate <NSObject>

- (void)showToastViewInCell:(UITableViewCell *)cell toastText:(NSString *)toastText;

/**
 * 该委托定义了cell中重新发送；
 * @param resendData 重新发送的字典 [text/image/voice : data]
 */
- (void)resendMessageInCell:(UITableViewCell *)cell resendData:(NSDictionary *)resendData;

/**
 * 消息中与regexs中的正则表达式匹配上的内容被点击的协议（若regexs使用默认值，可以不用实现该方法）
 * @param content 被点击的消息
 * @param selectedContent 与正则表达式匹配的内容
 */

- (void)didSelectMessageInCell:(UITableViewCell *)cell messageContent:(NSString *)content selectedContent:(NSString *)selectedContent;

/**
 *  点击了语音消息的委托方法
 */
- (void)didTapMessageInCell:(UITableViewCell *)cell;

/**
 *  点击了菜单
 */
- (void)didTapMenuWithText:(NSString *)menuText;

/**
 *  点击了引导按钮
 */
- (void)didTapGuideWithText:(NSString *)guideText;

/**
 *  点击了转人工
 */
- (void)didTapBotRedirectBtn;

/**
 重新加载制定 cell
 */
- (void)reloadCellAsContentUpdated:(UITableViewCell *)cell messageId:(NSString *)messageId;

/**
 删除cell
 */
- (void)deleteCell:(UITableViewCell *)cell withTipMsg:(NSString *)tipMsg enableLinesDisplay:(BOOL)enable;

/**
 更换tipCell
 */
- (void)replaceTipCell:(UITableViewCell *)cell;

/**
 * 显示播放视频的controller
 * @param videoLocalPath 视频本地缓存路径，
 * @param videoServer 视频服务器路径，
 */
- (void)showPlayVideoControllerWith:(NSString *)videoLocalPath serverPath:(NSString *)videoServer;

/**
 *  点击了商品卡片
 *  @param productUrl 商品链接
 */
- (void)didTapProductCard:(NSString *)productUrl;

@end


/**
 * MXChatBaseCell定义了客服聊天界面所有cell的父cell，开发者自定义的Cell请继承该Cell
 */
@interface MXChatBaseCell : UITableViewCell <MXChatCellProtocol>

/**
 *  ChatCell的代理
 */
@property (nonatomic, weak) id<MXChatCellDelegate> chatCellDelegate;

/**
 *  发送过来的消息气泡图片
 */
@property (nonatomic, strong) UIImage *incomingBubbleImage;

/**
 *  发送出去的消息气泡图片
 */
@property (nonatomic, strong) UIImage *outgoingBubbleImage;

/**
 *  消息气泡的frame
 */
@property (nonatomic, assign) CGRect cellFrame;


- (void)showMenuControllerInView:(UIView *)inView
                      targetRect:(CGRect)targetRect
                   menuItemsName:(NSDictionary *)menuItemsName;


@end
