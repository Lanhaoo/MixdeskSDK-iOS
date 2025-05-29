//
//  ViewController.m
//  Mixdesk-SDK-Demo
//
//  Created by xulianpeng on 2017/12/18.
//  Copyright © 2017年 Mixdesk. All rights reserved.
//

#import "ViewController.h"
#import "MXChatViewManager.h"
#import "MXChatDeviceUtil.h"
#import "DevelopViewController.h"
#import <MixdeskSDK/MixdeskSDK.h>
#import "NSArray+MXFunctional.h"
#import "MXBundleUtil.h"
#import "MXAssetUtil.h"
#import "MXImageUtil.h"
#import "MXToast.h"
#import "AppDelegate.h"
#import "MXProductCardMessage.h"

#import <MixdeskSDK/MXManager.h>

#import "MXManagerAPITestViewController.h"

#import "MXWebViewViewController.h"

#define AgentIDInTest @"501d1e0e520d8896629c34b538f57223"
@interface ViewController ()
@property (nonatomic, strong) NSNumber *unreadMessagesCount;

@end
static CGFloat const kMXButtonVerticalSpacing   = 16.0;
static CGFloat const kMXButtonHeight            = 42.0;
static CGFloat const kMXButtonToBottomSpacing   = 128.0;
@implementation ViewController{
    UIImageView *appIconImageView;
    UIButton *basicFunctionBtn;
    UIButton *devFunctionBtn;
    CGRect deviceFrame;
    CGFloat buttonWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    deviceFrame = [MXChatDeviceUtil getDeviceFrameRect:self];
    buttonWidth = deviceFrame.size.width / 2;
    self.navigationItem.title = @"Mixdesk SDK";
    
    [self initAppIcon];
    [self initFunctionButtons];
    
}


#pragma mark  集成第五步: 跳转到聊天界面

- (void)pushToMixdeskVC:(UIButton *)button {
    
//    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
//    MXChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [aStyle setEnableRoundAvatar:YES];
//    aStyle.backgroundColor = UIColor.blackColor;
//    aStyle.navBarColor = UIColor.redColor;
//    aStyle.navBarTintColor = UIColor.blueColor;
//    aStyle.navTitleColor = UIColor.whiteColor;
//    [aStyle setNavBackButtonImage:[UIImage imageNamed:@"sx_left"]];
//    aStyle.incomingBubbleColor = UIColor.yellowColor;
//    aStyle.outgoingBubbleColor = UIColor.blueColor;
//    aStyle.incomingMsgTextColor = UIColor.orangeColor;
//    aStyle.outgoingMsgTextColor = UIColor.purpleColor;
//    aStyle.statusBarStyle = UIStatusBarStyleLightContent;
////    NSDictionary* clientCustomizedAttrs = @{
////                                            @"name"        : userTool.user.name,
////                                            @"avatar"      : userTool.user.headImage,
////                                            @"gender"      : userTool.user.sex,
////                                            @"tel"         : userTool.user.phone
////                                            };
////    [chatViewManager setClientInfo:clientCustomizedAttrs override:YES];
////    if (kSelfUserId!=0){
////        [chatViewManager setLoginCustomizedId:[NSString stringWithFormat:@"%d",kSelfUserId]];
////    }
//    [chatViewManager z:self];
    
    
#pragma mark 总之, 要自定义UI层  请参考 MXChatViewStyle.h类中的相关的方法 ,要修改逻辑相关的 请参考MXChatViewManager.h中相关的方法
    
#pragma mark  最简单的集成方法: 全部使用mixdesk的,  不做任何自定义UI.
    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
    [chatViewManager setClientInfo:@{@"tel":@"18233598478",@"qq":@"484568756",@"email":@"4554455788@qq.com"} override:YES];
    [chatViewManager pushMXChatViewControllerInViewController:self];
    
//
#pragma mark  觉得返回按钮系统的太丑 想自定义 采用下面的方法
//    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
//    MXChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [chatViewManager setChatViewStyle:[MXChatViewStyle darkStyle]];
//    [aStyle setNavBarTintColor:[UIColor blueColor]];
//    [aStyle setNavBarColor:[UIColor redColor]];
////    aStyle.backgroundColor = UIColor.blackColor;
//    [aStyle setNavBackButtonImage:[UIImage imageNamed:@"mixdesk-icon"]];
//    [chatViewManager presentMXChatViewControllerInViewController:self];
#pragma mark 觉得头像 方形不好看 ,设置为圆形.
//    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
//    MXChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [aStyle setEnableRoundAvatar:YES];
//    [aStyle setEnableOutgoingAvatar:NO]; //不显示用户头像
//    [aStyle setEnableIncomingAvatar:NO]; //不显示客服头像
//    [chatViewManager pushMXChatViewControllerInViewController:self];
#pragma mark 导航栏 右按钮 想自定义 ,但是不到万不得已,不推荐使用这个,会造成mixdesk功能的缺失,因为这个按钮 1 当你在工作台打开机器人开关后 显示转人工,点击转为人工客服. 2在人工客服时 还可以评价客服
//    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
//    MXChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
//    [bt setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [aStyle setNavBarRightButton:bt];
//    [chatViewManager pushMXChatViewControllerInViewController:self];
#pragma mark 客户自定义信息
//    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
//    [chatViewManager setClientInfo:@{@"name":@"Mixdesk测试777",@"gender":@"woman22",@"age":@"400",@"address":@"北京昌平回龙观"} override:YES];
//    [chatViewManager setClientInfo:@{@"name":@"123测试123",@"gender":@"man11",@"age":@"100"}];
//    [chatViewManager setLoginCustomizedId:@"12313812381263786786123698"];
//    [chatViewManager pushMXChatViewControllerInViewController:self];

#pragma mark 预发送消息
//    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
////    [chatViewManager setPreSendMessages: @[@"我想咨询的订单号：【1705045496811】"]];
////     发送商品卡片
//    MXProductCardMessage *productCard = [[MXProductCardMessage alloc] initWithPictureUrl:@"https://file.pisen.com.cn/QJW3C1000WEB/Product/201701/16305409655404.jpg" title:@"商品的title" description:@"这件商品的描述内容，想怎么写就怎么写，哎呦，就是这么嗨！！！！" productUrl:@"https://mixdesk.com" andSalesCount:100];
//    [chatViewManager setPreSendMessages: @[productCard]];
//    [chatViewManager pushMXChatViewControllerInViewController:self];
    
#pragma mark 如果你想绑定自己的用户系统 ,当然推荐你使用 客户自定义信息来绑定用户的相关个人信息
#pragma mark 切记切记切记  一定要确保 customId 是唯一的,这样保证  customId和mixdesk生成的用户ID是一对一的
//    MXChatViewManager *chatViewManager = [[MXChatViewManager alloc] init];
//    NSString *customId = @"获取你们自己的用户ID 或 其他唯一标识的";
//    if (customId){
//        [chatViewManager setLoginCustomizedId:customId];
//    }else{
//   #pragma mark 切记切记切记 下面这一行是错误的写法 , 这样会导致 ID = "notadda" 和 mixdesk多个用户绑定,最终导致 对话内容错乱 A客户能看到 B C D的客户的对话内容
//        //[chatViewManager setLoginCustomizedId:@"notadda"];
//    }
//    [chatViewManager pushMXChatViewControllerInViewController:self];
}

#pragma 开发者的高级功能 其中有调用MixdeskSDK的API接口
- (void)didTapDevFunctionBtn:(UIButton *)button {
    //开发者功能
    DevelopViewController *viewController = [[DevelopViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)initAppIcon {
    CGFloat imageWidth = deviceFrame.size.width / 4;
    appIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mixdesk-icon"]];
    appIconImageView.frame = CGRectMake(deviceFrame.size.width/2 - imageWidth/2, deviceFrame.size.height / 4, imageWidth, imageWidth);
    appIconImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:appIconImageView];
}

- (void)initFunctionButtons {
    devFunctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    devFunctionBtn.frame = CGRectMake(deviceFrame.size.width/2 - buttonWidth/2, deviceFrame.size.height - kMXButtonToBottomSpacing, buttonWidth, kMXButtonHeight);
    devFunctionBtn.backgroundColor = [UIColor colorWithRed:8 / 255.0 green:203 / 255.0 blue:96 / 255.0 alpha:1];
    [devFunctionBtn setTitle:@"开发者功能" forState:UIControlStateNormal];
    [devFunctionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:devFunctionBtn];
    
    basicFunctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    basicFunctionBtn.frame = CGRectMake(devFunctionBtn.frame.origin.x, devFunctionBtn.frame.origin.y - kMXButtonVerticalSpacing - kMXButtonHeight, buttonWidth, kMXButtonHeight);
    basicFunctionBtn.backgroundColor = [UIColor colorWithRed:8 / 255.0 green:203 / 255.0 blue:96 / 255.0 alpha:1];
    [basicFunctionBtn setTitle:@"在线客服" forState:UIControlStateNormal];
    [basicFunctionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:basicFunctionBtn];
    
    [devFunctionBtn addTarget:self action:@selector(didTapDevFunctionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [basicFunctionBtn addTarget:self action:@selector(pushToMixdeskVC:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *webViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    webViewBtn.frame = CGRectMake(devFunctionBtn.frame.origin.x, devFunctionBtn.frame.origin.y + devFunctionBtn.frame.size.height + kMXButtonVerticalSpacing, buttonWidth, kMXButtonHeight);
    webViewBtn.backgroundColor = [UIColor colorWithRed:8 / 255.0 green:203 / 255.0 blue:96 / 255.0 alpha:1];
    [webViewBtn setTitle:@"聊天链接" forState:UIControlStateNormal];
    [webViewBtn addTarget:self action:@selector(gotoWebView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:webViewBtn];
}

- (void)gotoWebView {
    MXWebViewViewController *vc = [[MXWebViewViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
