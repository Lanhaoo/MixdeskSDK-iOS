//
//  MXManagerAPITestViewController.m
//  MXEcoboostSDK-test
//
//  Created by qipeng_yuhao on 2019/12/4.
//  Copyright © 2019 ijinmao. All rights reserved.
//

#import "MXManagerAPITestViewController.h"
#import <MixdeskSDK/MixdeskSDK.h>

@interface MXManagerAPITestViewController ()

@end

@implementation MXManagerAPITestViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    /**
     typedef NS_ENUM(NSUInteger, MXState) {
         MXStateUninitialized,
         MXStateInitialized,
         MXStateOffline, // not using
         MXStateUnallocatedAgent,
         MXStateAllocatingAgent,
         MXStateAllocatedAgent,
         MXStateBlacklisted,
     };
     */
    NSLog(@"currentState:%lu",(unsigned long)[MXManager getCurrentState]);
    NSLog(@"localAppKeys:%@",[MXManager getLocalAppKeys]);
    NSLog(@"currentAppKey:%@",[MXManager getCurrentAppKey]);
    NSLog(@"currentClientinfo:%@",[MXManager getCurrentClientInfo]);
    
    [MXManager addStateObserverWithBlock:^(MXState oldState, MXState newState, NSDictionary *value, NSError *error) {
        NSLog(@"addStateObserverWithBlock\n oldState:%lu newState:%lu",(unsigned long)oldState,(unsigned long)newState);
    } withKey:@"MXManagerAPITestViewController"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MXManager removeStateChangeObserverWithKey:@"MXManagerAPITestViewController"];
}

@end
