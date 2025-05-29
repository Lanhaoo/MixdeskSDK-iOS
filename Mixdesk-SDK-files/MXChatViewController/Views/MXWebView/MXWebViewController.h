//
//  MXWebViewController.h
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/15.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MXWebViewController : UIViewController

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *contentHTML;
@property (nonatomic, strong) WKWebView *webView;

@end
