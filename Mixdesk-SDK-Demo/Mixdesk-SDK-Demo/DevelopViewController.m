//
//  DevelopViewController.m
//  MXEcoboostSDK-test
//
//  Created by ijinmao on 15/12/3.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "DevelopViewController.h"
#import "MXChatViewManager.h"
#import <MixdeskSDK/MXManager.h>
#import "MXAssetUtil.h"
#import "MXToast.h"
#import "NSArray+MXFunctional.h"
#import "MXNotificationManager.h"

#define MX_DEMO_ALERTVIEW_TAG 3000
#define MX_DEMO_ALERTVIEW_TAG_APPKEY 4000
#define MX_DEMO_ALERTVIEW_TAG_PRESENDMSG 4001

typedef enum : NSUInteger {
    MXSDKDemoManagerClientId = 0,
    MXSDKDemoManagerCustomizedId,
    MXSDKDemoManagerAgentId,
    MXSDKDemoManagerGroupId,
    MXSDKDemoManagerClientAttrs,
    MXSDKDemoManagerClientOffline,
    MXSDKDemoManagerEndConversation,
    MXSDKDemoManagerCustomizedIdUnreadCount
} MXSDKDemoManager;

static CGFloat   const kMXSDKDemoTableCellHeight = 56.0;
static NSString * kSwitchShowUnreadMessageCount = @"kSwitchShowUnreadMessageCount";


@interface DevelopViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate>

@end

@implementation DevelopViewController{
    UITableView *configTableView;
    NSArray *sectionHeaders;
    NSArray *sectionTextArray;
    NSString *currentClientId;
    NSDictionary *clientCustomizedAttrs;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    sectionHeaders = @[
                       @"以下是开发者可能会用到的客服功能，请参考^.^",
                       @"以下是开源界面的不同的设置"
                       ];
    
    sectionTextArray = @[
                         @[
                             @"使用当前的联系人 id 上线，并同步消息",
                             @"输入Mixdesk联系人 id 进行上线",
                             @"输入自定义 id 进行上线",
                             @"查看当前Mixdesk联系人 id",
                             @"建立一个全新Mixdesk联系人 id 账号",
                             @"上传该联系人的自定义信息",
                             @"设置当前联系人为离线状态",
                             @"结束当前对话",
                             @"删除所有Mixdesk多媒体存储",
                             @"删除本地数据库中的消息",
                             @"查看当前 SDK 版本号",
                             @"当前的Mixdesk联系人 id 为：(点击复制该联系人 id )",
                             @"显示当前未读的消息数",
                             @"预发送消息上线",
                             @"切换 appKey 上线",
                             @"获取当前联系人的群发消息",
                             @"显示自定义id未读的消息数"
                             ],
                         @[
                             @"自定义主题 1",
                             @"自定义主题 2",
                             @"自定义主题 3",
                             @"自定义主题 4",
                             @"自定义主题 5",
                             @"自定义主题 6",
                             @"系统主题 MXChatViewStyleTypeBlue",
                             @"系统主题 MXChatViewStyleTypeGreen",
                             @"系统主题 MXChatViewStyleTypeDark",
                             ]
                         ];
    
    clientCustomizedAttrs = @{
                              @"name"       :   @"Kobe Bryant"
                              };
    
    [self initNavBar];
    [self initTableView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //等待sdk初始化成功
        self->currentClientId = [MXManager getCurrentClientId];
        [self->configTableView reloadData];
    });
    
    //在聊天界面外，监听是否收到了客服消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMXMessages:) name:MX_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    currentClientId = [MXManager getCurrentClientId];
    [configTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavBar {
    self.navigationItem.title = @"MixdeskSDK";
}

- (void)initTableView {
    configTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    configTableView.delegate = self;
    configTableView.dataSource = self;
    [self.view addSubview:configTableView];
}

- (void)didReceiveNewMXMessages:(NSNotification *)notification {
    
//    NSArray *messages = [notification userInfo][@"messages"];
//    if (self.view.window) {
//        [MXToast showToast:[NSString stringWithFormat:@"New message from '%@': %@",[MXManager appKeyForMessage:[messages firstObject]],[[messages firstObject] content]] duration:2 window:self.view.window];
//    }
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMXSDKDemoTableCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self setCurrentClientOnline];
                break;
            case 1:
                [self inputClientId];
                break;
            case 2:
                [self inputCustomizedId];
                break;
            case 3:
                [self getCurrentClientId];
                break;
            case 4:
                [self creatMXClient];
                break;
            case 5:
                [self showSetClientAttributesAlertView];
                break;
            case 6:
                [self showSetClientOfflineAlertView];
                break;
            case 7:
                [self showEndConversationAlertView];
                break;
            case 8:
                [self removeMixdeskMediaData];
                break;
            case 9:
                [self removeAllMesagesFromDatabase];
                break;
            case 10:
                [self getMixdeskSDKVersion];
                break;
            case 11:
                [self copyCurrentClientIdToPasteboard];
                break;
            case 12:
                [self showUnreadMessageCount:[tableView cellForRowAtIndexPath:indexPath]];
                break;
            case 13:
                [self presentMessageAndOnline];
                break;
            case 14:
                [self switchAppKey];
                break;
            case 15:
                [self getCurrentClientGroupNotifications];
                break;
            case 16:
                [self inputCustomizedIdGetUnreadMessageCount];
                break;
            default:
                break;
        }
        return;
    }
    switch (indexPath.row) {
        case 0:
            [self chatViewStyle1];
            break;
        case 1:
            [self chatViewStyle2];
            break;
        case 2:
            [self chatViewStyle3];
            break;
        case 3:
            [self chatViewStyle4];
            break;
        case 4:
            [self chatViewStyle5];
            break;
        case 5:
            [self chatViewStyle6];
            break;
        case 6:
            [self systemStyleBlue];
            break;
        case 7:
            [self systemStyleGreen];
            break;
        case 8:
            [self systemStyleDark];
            break;
        default:
            break;
    }
}

#pragma UITableViewDataSource
- (void)switchAppKey {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"已注册的 app key 列表" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"新建"];
    
    for (NSString *appKey in [MXManager getLocalAppKeys]) {
        [actionSheet addButtonWithTitle:appKey];
    }

    [actionSheet showInView:self.view];
}

- (void)presentMessageAndOnline {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入预发送消息" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MX_DEMO_ALERTVIEW_TAG_PRESENDMSG;
    [alertView show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    } else if (buttonIndex == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新建 app key" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = MX_DEMO_ALERTVIEW_TAG_APPKEY;
        [alertView show];
    } else {
        NSString *selectedAppkey = [MXManager getLocalAppKeys][buttonIndex - 2];
        
        [MXManager initWithAppkey:selectedAppkey completion:^(NSString *clientId, NSError *error) {
            if (!error) {
                MXChatViewManager *chatViewManager = [MXChatViewManager new];
                [chatViewManager pushMXChatViewControllerInViewController:self];
            }
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sectionHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[sectionTextArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *textArray = [sectionTextArray objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[textArray objectAtIndex:indexPath.row]];
    if (!cell){
        if (indexPath.row + 1 == [textArray count] && indexPath.section == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[textArray objectAtIndex:indexPath.row]];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[textArray objectAtIndex:indexPath.row]];
        }
    }
    
    cell.accessoryView = nil;
    cell.detailTextLabel.text = nil;
    if (indexPath.row + 2 == [textArray count] && indexPath.section == 0) {
        cell.detailTextLabel.text = currentClientId;
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor darkTextColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
    cell.textLabel.text = [textArray objectAtIndex:indexPath.row];
    return cell;
}

/**
 *  当前联系人id上线
 */
- (void)setCurrentClientOnline {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    //开启同步消息
    [chatViewManager enableSyncServerMessage:true];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewManager pushMXChatViewControllerInViewController:self];
}

/**
 *  输入联系人id
 */
- (void)inputClientId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入Mixdesk联系人id" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerClientId;
    [alertView show];
}

/**
 *  使用联系人id上线
 *
 *  @param clientId 联系人id
 */
- (void)setClientOnlineWithClientId:(NSString *)clientId {
    clientId = @"2eDTdfN0zDy7uWedvV4RZliXAVh";
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager setLoginMXClientId:clientId];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewManager.chatViewStyle setIncomingBubbleColor:[UIColor mx_colorWithHexString:@"#00CE7D"]];
    [chatViewManager.chatViewStyle setIncomingMsgTextColor:[UIColor mx_colorWithHexString:@"#FF5C5E"]];
    [chatViewManager.chatViewStyle setOutgoingBubbleColor:[UIColor mx_colorWithHexString:@"#FFB652"]];
    [chatViewManager.chatViewStyle setOutgoingMsgTextColor:[UIColor mx_colorWithHexString:@"#17C7D1"]];
    [chatViewManager.chatViewStyle setBackgroundColor:[UIColor mx_colorWithHexString:@"#303D42"]];
    [chatViewManager.chatViewStyle setEventTextColor:[UIColor purpleColor]];
    [chatViewManager presentMXChatViewControllerInViewController:self];
}

- (void)setClientOnlineWithPresendMessage:(NSString *)messageString {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager setPreSendMessages:@[messageString]];
    [chatViewManager presentMXChatViewControllerInViewController:self];

}

/**
 *  输入开发者自定义id
 */
- (void)inputCustomizedId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入自定义Id进行上线" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerCustomizedId;
    [alertView show];
}

/**
 *  使用自定义id上线
 *
 *  @param customizedId 自定义id
 */
- (void)setClientOnlineWithCustomizedId:(NSString *)customizedId {
//    [MXManager initWithAppkey:@"" completion:^(NSString *clientId, NSError *error) {
//        if (!error) {
            MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
            [chatViewManager setLoginCustomizedId:customizedId];
            [chatViewManager pushMXChatViewControllerInViewController:self];
//        }
//    }];
    
}

/**
 *  获取当前联系人id
 */
- (void)getCurrentClientId {
    NSString *clientId = [MXManager getCurrentClientId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前的Mixdesk联系人id为：" message:clientId delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alertView show];
}

/**
 *  创建一个新的联系人
 */
- (void)creatMXClient {
    [MXManager createClient:^(NSString *clientId, NSError *error) {
        if (!error) {
            self->currentClientId = clientId;
            [self->configTableView reloadData];
            NSString *clientId = [MXManager getCurrentClientId];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新的Mixdesk联系人id为：" message:clientId delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        } else {
            NSLog(@"新建Mixdesk client失败");
        }
    }];
}

/**
 *  显示 设置联系人离线 的alertView
 */
- (void)showSetClientOfflineAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设置当前联系人离线吗？" message:@"Mixdesk建议，退出聊天界面，不需要让联系人离线，这样 SDK 还能接收客服发送的消息。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerClientOffline;
    [alertView show];
}

/**
 *  主动设置当前联系人离线。Mixdesk建议，退出聊天界面，不需要让联系人离线，这样 SDK 还能接收客服发送的消息
 */
- (void)setCurrentClientOffline {
    [MXManager setClientOffline];
}

- (void)showEndConversationAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结束当前对话吗？" message:@"Mixdesk建议，让Mixdesk后台自动超时结束对话，否则结束对话后，联系人得重新分配客服，建了一个新的客服对话。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerEndConversation;
    [alertView show];
}

/**
 *  主动结束当前对话。Mixdesk建议，让Mixdesk后台自动超时结束对话，否则结束对话后，联系人得重新分配客服，建了一个新的客服对话。
 */
- (void)endCurrentConversation {
    [MXManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [MXToast showToast:@"对话已结束" duration:1.0 window:self.view];
        } else {
            [MXToast showToast:@"对话结束失败" duration:1.0 window:self.view];
        }
    }];
}

/**
 *  删除Mixdesk多媒体存储
 */
- (void)removeMixdeskMediaData {
    [MXManager removeAllMediaDataWithCompletion:^(float mediaSize) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"已为您移除多媒体存储，共 %f M", mediaSize] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }];
}

/**
 *  删除本地数据库中的消息
 */
- (void)removeAllMesagesFromDatabase {
    [MXManager removeAllMessageFromDatabaseWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已删除本地数据库中的消息" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"抱歉，删除本地数据库消息失败了>.<" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)getMixdeskSDKVersion {
    NSString *sdkVersion = [MXManager getMixdeskSDKVersion];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"当前Mixdesk SDK 版本号为：%@", sdkVersion] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alertView show];
}

/**
 *  复制当前联系人id到剪切板
 */
- (void)copyCurrentClientIdToPasteboard {
    [UIPasteboard generalPasteboard].string = currentClientId;
    [MXToast showToast:@"已复制" duration:0.5 window:self.view];
}

/**
 *  显示用户退出应用后收到的未读消息数的开关
 */
- (void)switchShowUnreadMessageCount {
    [[NSUserDefaults standardUserDefaults]setObject:@(![self.class shouldShowUnreadMessageCount]) forKey:kSwitchShowUnreadMessageCount];
    [configTableView reloadData];
}

+ (BOOL)shouldShowUnreadMessageCount {
    return [[[NSUserDefaults standardUserDefaults]objectForKey:kSwitchShowUnreadMessageCount] boolValue];
}

- (void)showUnreadMessageCount:(UITableViewCell *)cell {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [indicator startAnimating];
    [cell setAccessoryView:indicator];
    
    [MXServiceToViewInterface getUnreadMessagesWithCompletion:^(NSArray *messages, NSError *error) {
        [indicator stopAnimating];
        cell.accessoryView = nil;
        UIAlertView *alert = [UIAlertView new];
        alert.title = @"未读消息";
        alert.message = [NSString stringWithFormat:@"未读消息数为: %d",(int)messages.count];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }];
}

- (void)showUnreadMessageCountWithCustomizedId:(NSString *)customizedId {
    NSLog(@"input customizedId === %@", customizedId);
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [indicator startAnimating];
    
    [MXServiceToViewInterface getUnreadMessagesWithCustomizedId:customizedId withCompletion:^(NSArray *messages, NSError *error) {
        [indicator stopAnimating];
        UIAlertView *alert = [UIAlertView new];
        alert.title = @"未读消息";
        alert.message = error.localizedDescription.length > 0 ? error.localizedDescription : [NSString stringWithFormat:@"未读消息数为: %d",(int)messages.count];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }];
}

/**
 *  显示联系人的属性
 */
- (void)showSetClientAttributesAlertView {
    NSString *attrs = [NSString stringWithCString:[clientCustomizedAttrs.description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"上传下列属性吗？" message:attrs delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerClientAttrs;
    [alertView show];
}

/**
 *  上传联系人的属性
 */
- (void)uploadClientAttributes {
    //注意这个接口是将联系人信息上传到当前的联系人上。
    [MXManager setClientInfo:clientCustomizedAttrs completion:^(BOOL success, NSError *error) {
        NSString *alertString = @"上传联系人自定义信息成功~";
        NSString *message = @"您可前往Mixdesk工作台，查看该联系人的信息是否有修改";
        if (!success) {
            alertString = @"上传联系人自定义信息失败";
            message = @"请检查当前的Mixdesk联系人id是否还没有显示出来(红色字体)，没有显示出即表示没有成功初始化SDK";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertString message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }];
}

/**
 *  获取当前联系人的群发消息数
 */
- (void)getCurrentClientGroupNotifications {
    if (currentClientId) {
        [[MXNotificationManager sharedManager] openMXGroupNotificationServer];
    }
}

/**
 *  输入自定义Id获取未读消息数<##>
 */
- (void)inputCustomizedIdGetUnreadMessageCount {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入自定义Id获取未读消息数" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerCustomizedIdUnreadCount;
    [alertView show];
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        switch (alertView.tag) {
            case MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerClientId:
                [self setClientOnlineWithClientId:[alertView textFieldAtIndex:0].text];
                break;
            case MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerCustomizedId:
                [self setClientOnlineWithCustomizedId:[alertView textFieldAtIndex:0].text];
                break;
            case MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerClientAttrs:
                [self uploadClientAttributes];
                break;
            case MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerClientOffline:
                [self setCurrentClientOffline];
                break;
            case MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerEndConversation:
                [self endCurrentConversation];
                break;
            case MX_DEMO_ALERTVIEW_TAG_APPKEY: {
                [MXManager initWithAppkey:[alertView textFieldAtIndex:0].text completion:^(NSString *clientId, NSError *error) {
                    if (!error) {
                        MXChatViewManager *chatViewManager = [MXChatViewManager new];
                        [chatViewManager pushMXChatViewControllerInViewController:self];
                    }else{
                        [MXToast showToast:@"创建appkey失败" duration:1.0 window:self.view];
                    }
                }];
            }
                break;
            case MX_DEMO_ALERTVIEW_TAG_PRESENDMSG: {
                [self setClientOnlineWithPresendMessage:[alertView textFieldAtIndex:0].text];
            }
                break;
            case MX_DEMO_ALERTVIEW_TAG + (int)MXSDKDemoManagerCustomizedIdUnreadCount: {
                [self showUnreadMessageCountWithCustomizedId:[alertView textFieldAtIndex:0].text];
            }
                break;
            default:
                break;
        }
    }
}

/**
 *  开发者这样配置可：底部按钮、修改气泡颜色、文字颜色、使头像设为圆形
 */
- (void)chatViewStyle1 {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    UIImage *photoImage = [UIImage imageNamed:@"MXMessageCameraInputImageNormalStyleOne"];
    UIImage *photoHighlightedImage = [UIImage imageNamed:@"MXMessageCameraInputHighlightedImageStyleTwo"];
    UIImage *voiceImage = [UIImage imageNamed:@"MXMessageVoiceInputImageNormalStyleTwo"];
    UIImage *voiceHighlightedImage = [UIImage imageNamed:@"MXMessageVoiceInputHighlightedImageStyleTwo"];
    UIImage *keyboardImage = [UIImage imageNamed:@"MXMessageTextInputImageNormalStyleTwo"];
    UIImage *keyboardHighlightedImage = [UIImage imageNamed:@"MXMessageTextInputHighlightedImageStyleTwo"];
    UIImage *resightKeyboardImage = [UIImage imageNamed:@"MXMessageKeyboardDownImageNormalStyleTwo"];
    UIImage *resightKeyboardHighlightedImage = [UIImage imageNamed:@"MXMessageKeyboardDownHighlightedImageStyleTwo"];
    UIImage *avatar = [UIImage imageNamed:@"ijinmaoAvatar"];
    
    MXChatViewStyle *chatViewStyle = [chatViewManager chatViewStyle];
    
    [chatViewStyle setPhotoSenderImage:photoImage];
    [chatViewStyle setPhotoSenderHighlightedImage:photoHighlightedImage];
    [chatViewStyle setVoiceSenderImage:voiceImage];
    [chatViewStyle setVoiceSenderHighlightedImage:voiceHighlightedImage];
    [chatViewStyle setIncomingBubbleColor:[UIColor redColor]];
    [chatViewStyle setIncomingMsgTextColor:[UIColor whiteColor]];
    [chatViewStyle setOutgoingBubbleColor:[UIColor yellowColor]];
    [chatViewStyle setOutgoingMsgTextColor:[UIColor darkTextColor]];
    [chatViewStyle setEnableRoundAvatar:true];
    
    [chatViewManager setoutgoingDefaultAvatarImage:avatar];
    [chatViewManager pushMXChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：是否支持发送语音、是否显示本机头像、修改气泡的样式
 */
- (void)chatViewStyle2 {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    UIImage *incomingBubbleImage = [UIImage imageNamed:@"MXBubbleIncomingStyleTwo"];
    UIImage *outgoingBubbleImage = [UIImage imageNamed:@"MXBubbleOutgoingStyleTwo"];
    CGPoint stretchPoint = CGPointMake(incomingBubbleImage.size.width / 2.0f - 4.0, incomingBubbleImage.size.height / 2.0f);
    [chatViewManager enableSendVoiceMessage:false];
    [chatViewManager setIncomingMessageSoundFileName:@""];
    
    MXChatViewStyle *chatViewStyle = [chatViewManager chatViewStyle];
    
    [chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewStyle setIncomingBubbleImage:incomingBubbleImage];
    [chatViewStyle setOutgoingBubbleImage:outgoingBubbleImage];
    [chatViewStyle setIncomingBubbleColor:[[UIColor yellowColor] colorWithAlphaComponent:0.3]];
    [chatViewStyle setOutgoingBubbleColor:[[UIColor blueColor]colorWithAlphaComponent:0.7]];
    [chatViewStyle setBubbleImageStretchInsets:UIEdgeInsetsMake(stretchPoint.y, stretchPoint.x, incomingBubbleImage.size.height-stretchPoint.y+0.5, stretchPoint.x)];
    [chatViewManager pushMXChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：增加可点击链接的正则表达式( Library 本身已支持多种格式链接，如未满足需求可增加)、增加欢迎语、是否开启消息声音、修改接受消息的铃声
 */
- (void)chatViewStyle3 {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager setIncomingMessageSoundFileName:@"MXNewMessageRingStyleTwo.wav"];
    [chatViewManager setMessageLinkRegex:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"];
    [chatViewManager enableChatWelcome:true];
    [chatViewManager setChatWelcomeText:@"yes，你好，请问有什么可以帮助到您？"];
    [chatViewManager enableMessageSound:true];
    [chatViewManager pushMXChatViewControllerInViewController:self];
    
}

/**
 *  如果 tableView 没有在底部，开发者这样可打开消息的提示
 */
- (void)chatViewStyle4 {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager enableShowNewMessageAlert:true];

    [chatViewManager pushMXChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：是否支持下拉刷新、修改下拉刷新颜色、增加导航栏标题
 */
- (void)chatViewStyle5 {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager enableTopPullRefresh:true];
    [chatViewManager.chatViewStyle setPullRefreshColor:[UIColor redColor]];
    [chatViewManager.chatViewStyle setNavBarTintColor:[UIColor redColor]];
//    [chatViewManager.chatViewStyle setNavBarColor:[UIColor yellowColor]];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor redColor];
    rightButton.frame = CGRectMake(10, 10, 20, 20);
    [chatViewManager.chatViewStyle setNavBarRightButton:rightButton];
    [chatViewManager setClientInfo:@{@"avatar":@"https://avatars3.githubusercontent.com/u/1302?v=3&s=96"}];
    [chatViewManager pushMXChatViewControllerInViewController:self];
}

/**
 *  开发者这样可修改导航栏颜色、导航栏左右键、取消图片消息的mask效果
 */

- (void)showAlert {
    [[[UIAlertView alloc] initWithTitle:@"test" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)chatViewStyle6 {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor redColor];
    rightButton.frame = CGRectMake(10, 10, 20, 20);
    [chatViewManager.chatViewStyle setNavBarTintColor:[UIColor redColor]];
    [rightButton addTarget: self action:@selector(showAlert) forControlEvents:(UIControlEventTouchUpInside)];
    [chatViewManager.chatViewStyle setNavBarRightButton:rightButton];
    UIButton *lertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lertButton.backgroundColor = [UIColor blueColor];
    lertButton.frame = CGRectMake(10, 10, 20, 20);
//    [chatViewManager.chatViewStyle setNavBarLeftButton:lertButton];
    //xlp
    [chatViewManager.chatViewStyle setNavBackButtonImage:[UIImage imageNamed:@"MXMessageCameraInputImageNormalStyleTwo"]];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleDefault];
    chatViewManager.chatViewStyle.navTitleColor = [UIColor yellowColor];
    
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    [chatViewManager setNavTitleText:@"我是标题哦^.^"];
    
//    [chatViewManager pushMXChatViewControllerInViewController:self];
    [chatViewManager presentMXChatViewControllerInViewController:self];
    
}

- (void)systemStyleBlue {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[MXChatViewStyle blueStyle]];
    [chatViewManager.chatViewStyle setNavBackButtonImage:[[UIImage imageNamed:@"ijinmaoAvatar"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushMXChatViewControllerInViewController:self];
}

- (void)systemStyleGreen {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[MXChatViewStyle greenStyle]];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushMXChatViewControllerInViewController:self];
}

- (void)systemStyleDark {
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[MXChatViewStyle darkStyle]];
    
    [MXCustomizedUIText setCustomiedTextForKey:MXUITextKeyRecordButtonBegin text:@"让我听见你的声音"];
    [MXCustomizedUIText setCustomiedTextForKey:(MXUITextKeyMessageInputPlaceholder) text:@"开始打字吧"];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushMXChatViewControllerInViewController:self];
}

//#pragma 监听收到Mixdesk聊天消息的广播
//- (void)didReceiveNewMXMessages:(NSNotification *)notification {
//    NSArray *messages = [notification.userInfo objectForKey:@"messages"];
//    for (MXMessage *message in messages) {
//        NSLog(@"messge content = %@", message.content);
//    }
//    NSLog(@"在聊天界面外，监听到了收到客服消息的广播");
//}


@end
