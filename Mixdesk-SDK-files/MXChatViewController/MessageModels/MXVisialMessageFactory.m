//
//  MXVisialMessageFactory.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 2016/11/17.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXVisialMessageFactory.h"
#import "MXCardMessage.h"
#import "MXFileDownloadMessage.h"
#import "MXHybridMessage.h"
#import "MXImageMessage.h"
#import "MXJsonUtil.h"
#import "MXPhotoCardMessage.h"
#import "MXProductCardMessage.h"
#import "MXRichTextMessage.h"
#import "MXServiceToViewInterface.h"
#import "MXTextMessage.h"
#import "MXVideoMessage.h"
#import "MXVoiceMessage.h"
#import "MXWithDrawMessage.h"

@implementation MXVisialMessageFactory

- (MXBaseMessage *)createMessage:(MXMessage *)plainMessage {
  MXBaseMessage *toMessage;
  switch (plainMessage.contentType) {
  case MXMessageContentTypeText: {
    MXTextMessage *textMessage =
        [[MXTextMessage alloc] initWithContent:plainMessage.content];
    textMessage.isSensitive = plainMessage.isSensitive;
    textMessage.tags = [self getMessageBottomTagModel:plainMessage];
    toMessage = textMessage;
    break;
  }
  case MXMessageContentTypeImage: {
    MXImageMessage *imageMessage =
        [[MXImageMessage alloc] initWithImagePath:plainMessage.content];
    imageMessage.quickBtns = [self getMessageBottomQuickBtnTagModel:plainMessage];
    toMessage = imageMessage;
    break;
  }
  case MXMessageContentTypeVoice: {
    MXVoiceMessage *voiceMessage =
        [[MXVoiceMessage alloc] initWithVoicePath:plainMessage.content];
    [voiceMessage handleAccessoryData:plainMessage.accessoryData];
    toMessage = voiceMessage;
    break;
  }
  case MXMessageContentTypeFile: {
    MXFileDownloadMessage *fileDownloadMessage = [[MXFileDownloadMessage alloc]
        initWithDictionary:plainMessage.accessoryData];
    toMessage = fileDownloadMessage;
    break;
  }
  case MXMessageContentTypeRichText: {
    MXRichTextMessage *richTextMessage = [[MXRichTextMessage alloc]
        initWithDictionary:plainMessage.accessoryData];
    richTextMessage.tags = [self getMessageBottomTagModel:plainMessage];
    richTextMessage.quickBtns =
        [self getMessageBottomQuickBtnTagModel:plainMessage];
    toMessage = richTextMessage;
    break;
  }
  case MXMessageContentTypeCard: {
    MXCardMessage *cardMessage = [[MXCardMessage alloc] init];
    cardMessage.cardData = plainMessage.cardData;
    toMessage = cardMessage;
    break;
  }
  case MXMessageContentTypeHybrid: {
    toMessage = [self messageFromContentTypeHybrid:plainMessage
                                   toMXBaseMessage:toMessage];
    break;
  }
  case MXMessageContentTypeVideo: {
    MXVideoMessage *videoMessage =
        [[MXVideoMessage alloc] initWithVideoServerPath:plainMessage.content];
    [videoMessage handleAccessoryData:plainMessage.accessoryData];
    toMessage = videoMessage;
    break;
  }
  default:
    break;
  }
  // 消息撤回
  if (plainMessage.isMessageWithDraw) {
    MXWithDrawMessage *withDrawMessage = [[MXWithDrawMessage alloc] init];
    withDrawMessage.isMessageWithDraw = plainMessage.isMessageWithDraw;
    withDrawMessage.content = @"消息已被客服撤回";
    toMessage = withDrawMessage;
    if (![MXServiceToViewInterface getEnterpriseConfigWithdrawToastStatus]) {
      return nil;
    }
  }
  toMessage.messageId = plainMessage.messageId;
  toMessage.date = plainMessage.createdOn;
  toMessage.userName = plainMessage.messageUserName;
  toMessage.userAvatarPath = plainMessage.messageAvatar;
  toMessage.conversionId = plainMessage.conversationId;
  switch (plainMessage.sendStatus) {
  case MXMessageSendStatusSuccess:
    toMessage.sendStatus = MXChatMessageSendStatusSuccess;
    break;
  case MXMessageSendStatusFailed:
    toMessage.sendStatus = MXChatMessageSendStatusFailure;
    break;
  case MXMessageSendStatusSending:
    toMessage.sendStatus = MXChatMessageSendStatusSending;
    break;
  default:
    break;
  }
  switch (plainMessage.fromType) {
  case MXMessageFromTypeAgent: {
    toMessage.fromType = MXChatMessageIncoming;
    break;
  }
  case MXMessageFromTypeClient: {
    toMessage.fromType = MXChatMessageOutgoing;
    break;
  }
  case MXMessageFromTypeAutomation: {
    toMessage.fromType = MXChatMessageIncoming;
    break;
  }
  case MXMessageFromTypeAiAgent: {
    toMessage.fromType = MXChatMessageIncoming;
    break;
  }
  default:
    break;
  }
  return toMessage;
}

- (MXBaseMessage *)messageFromContentTypeHybrid:(MXMessage *)message
                                toMXBaseMessage:(MXBaseMessage *)baseMessage {
  if (message.accessoryData &&
      [message.accessoryData isKindOfClass:[NSDictionary class]]) {
    NSDictionary *dataDic =
        [NSDictionary dictionaryWithDictionary:message.accessoryData];

    // 处理内容部分
    if ([dataDic objectForKey:@"content"] &&
        ![[dataDic objectForKey:@"content"] isEqual:[NSNull null]]) {
      NSArray *contentArr = [NSArray array];
      contentArr =
          [MXJsonUtil createWithJSONString:[dataDic objectForKey:@"content"]];

      if (contentArr.count > 0) {
        NSDictionary *contentDic = contentArr.firstObject;
        if ([contentDic[@"type"] isEqualToString:@"photo_card"]) {
          // 图片卡片类型
          MXPhotoCardMessage *photoCard = [[MXPhotoCardMessage alloc]
              initWithImagePath:contentDic[@"body"][@"pic_url"]
                     andUrlPath:contentDic[@"body"][@"target_url"]];
          baseMessage = photoCard;
        } else if ([contentDic[@"type"] isEqualToString:@"product_card"]) {
          // 产品卡片类型
          MXProductCardMessage *productCard = [[MXProductCardMessage alloc]
              initWithPictureUrl:contentDic[@"body"][@"pic_url"]
                           title:contentDic[@"body"][@"title"]
                     description:contentDic[@"body"][@"description"]
                      productUrl:contentDic[@"body"][@"product_url"]
                   andSalesCount:[contentDic[@"body"][@"sales_count"]
                                     longValue]];
          baseMessage = productCard;
        } else if ([contentDic[@"type"] isEqualToString:@"option"]) {
          // 初始化混合消息对象
          MXHybridMessage *hybridMessage =
              [[MXHybridMessage alloc] initWithDictionary:dataDic];
          // 使用MXHybridMessage中的方法处理用户反馈按钮
          [hybridMessage parseFeedbackButtonsFromDictionary:contentDic];
          // 设置不显示消息内容和头像
          hybridMessage.content = @"";
          hybridMessage.hideAvatar = YES;
          baseMessage = hybridMessage;
        }
      }
    }
  }

  return baseMessage;
}

/*
 * 注意点:
 * 1. 在线快捷按钮和automation 快捷按钮都是走这里
 *  1.1 通过 extra.conv_type === 'automation_clue' 区分 是在线还是automation
 */

- (NSArray *)getMessageBottomQuickBtnTagModel:(MXMessage *)message {
  if (message.accessoryData &&
      [message.accessoryData isKindOfClass:[NSDictionary class]]) {
    NSDictionary *dataDic =
        [NSDictionary dictionaryWithDictionary:message.accessoryData];
    if ([dataDic objectForKey:@"quick_btn"] &&
        ![[dataDic objectForKey:@"quick_btn"] isEqual:[NSNull null]]) {
      NSArray *tagArr = [dataDic objectForKey:@"quick_btn"];
      NSMutableArray *resultArr = [NSMutableArray array];
      for (NSDictionary *dic in tagArr) {
        // 需要添加func和func_id属性
        NSMutableDictionary *mutableDic =
            [NSMutableDictionary dictionaryWithDictionary:dic];
        [mutableDic setValue:@11 forKey:@"func"];
        [mutableDic setValue:@"" forKey:@"func_id"];

        [resultArr addObject:[[MXMessageBottomQuickBtnModel alloc]
                                 initWithDictionary:mutableDic]];
      }
      if (resultArr.count > 0) {
        return resultArr;
      }
    }
  }
  return nil;
}

- (NSArray *)getMessageBottomTagModel:(MXMessage *)message {
  if (message.accessoryData &&
      [message.accessoryData isKindOfClass:[NSDictionary class]]) {
    NSDictionary *dataDic =
        [NSDictionary dictionaryWithDictionary:message.accessoryData];
    if ([dataDic objectForKey:@"operator_msg"] &&
        ![[dataDic objectForKey:@"operator_msg"] isEqual:[NSNull null]]) {
      NSArray *tagArr = [dataDic objectForKey:@"operator_msg"];
      NSMutableArray *resultArr = [NSMutableArray array];
      for (NSDictionary *dic in tagArr) {
        [resultArr
            addObject:[[MXMessageBottomTagModel alloc] initWithDictionary:dic]];
      }
      if (resultArr.count > 0) {
        return resultArr;
      }
    }
  }
  return nil;
}

@end
