//
//  MXWebViewViewController.m
//  MXEcoboostSDK-test
//
//  Created by Cassie on 2023/12/14.
//  Copyright © 2023 Mixdesk Inc. All rights reserved.
//

#import "MXWebViewViewController.h"
#import <Webkit/WebKit.h>

@interface MXWebViewViewController ()<WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation MXWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *urlStr = @"";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *requestUrl = navigationAction.request.URL;
    NSString *scheme = [requestUrl scheme];
    UIApplication *app = [UIApplication sharedApplication];
    if ([scheme isEqualToString:@"tel"]) {
        if ([app canOpenURL:requestUrl]) {
            // 打电话
            [[UIApplication sharedApplication] openURL:requestUrl options:@{} completionHandler:^(BOOL success) {
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end

