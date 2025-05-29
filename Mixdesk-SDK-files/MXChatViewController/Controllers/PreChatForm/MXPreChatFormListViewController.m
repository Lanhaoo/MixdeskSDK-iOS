//
//  MXPreAdviseFormListViewController.m
//  Mixdesk-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Mixdesk. All rights reserved.
//

#import "MXPreChatFormListViewController.h"
#import "MXPreChatFormViewModel.h"
#import "MXBundleUtil.h"
#import "NSArray+MXFunctional.h"
#import "UIView+MXLayout.h"
#import "MXPreChatSubmitViewController.h"
#import "MXAssetUtil.h"
#import "MXPreChatTopView.h"

@interface MXPreChatFormListViewController ()

@property (nonatomic, strong) MXPreChatFormViewModel *viewModel;
@property (nonatomic, copy) void(^completeBlock)(NSDictionary *userInfo);
@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, strong) UIView *cacheHeaderView;

@end

@implementation MXPreChatFormListViewController

+ (MXPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(NSDictionary *userInfo))block cancle:(void(^)(void))cancelBlock {
    
    MXPreChatFormListViewController *preChatViewController = [MXPreChatFormListViewController new];
    preChatViewController.completeBlock = block;
    preChatViewController.cancelBlock = cancelBlock;
    
    __weak typeof(controller) weakController = controller;
    [preChatViewController.viewModel requestPreChatServeyDataIfNeed:^(MXPreChatData *data, NSError *error) {
        if (data && (data.form.formItems.count + data.menu.menuItems.count) > 0) {
            UINavigationController *nav;
            if ([data.menu.status isEqualToString:@"close"] || data.menu.menuItems.count == 0) {
                if (data.form.formItems.count > 0 && ![data.form.status isEqualToString:@"close"]) {
                    if (data.form.formItems.count == 1) {
                        MXPreChatFormItem *item = data.form.formItems.firstObject;
                        if ([item isKindOfClass: MXPreChatFormItem.class] && [item.displayName isEqual: @"验证码"]) {
                            // 单独只有一个验证码时直接跳过询前表单步骤
                            if (block) {
                                block(nil);
                            }
                        } else {
                            MXPreChatSubmitViewController *submitViewController = [MXPreChatSubmitViewController new];
                            submitViewController.formData = data;
                            submitViewController.completeBlock = block;
                            submitViewController.cancelBlock = cancelBlock;
                            nav = [[UINavigationController alloc] initWithRootViewController:submitViewController];
                        }
                    } else {
                        MXPreChatSubmitViewController *submitViewController = [MXPreChatSubmitViewController new];
                        submitViewController.formData = data;
                        submitViewController.completeBlock = block;
                        submitViewController.cancelBlock = cancelBlock;
                        nav = [[UINavigationController alloc] initWithRootViewController:submitViewController];
                    }
                } else {
                    if (block) {
                        block(nil);
                    }
                }
            } else {
                nav = [[UINavigationController alloc] initWithRootViewController:preChatViewController];
            }
            
            nav.navigationBar.barTintColor = weakController.navigationController.navigationBar.barTintColor;
            nav.navigationBar.tintColor = weakController.navigationController.navigationBar.tintColor;
            if (nav) {
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [weakController presentViewController:nav animated:YES completion:nil];
            } else {
                if (block) {
                    block(nil);
                }
            }
        } else {
            if (block) {
                block(nil);
            }
        }
    }];
    
    return preChatViewController;
}

- (instancetype)init {
    if (self = [super initWithStyle:(UITableViewStyleGrouped)]) {
        self.viewModel = [MXPreChatFormViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithImage:[MXAssetUtil backArrow] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    if (self.viewModel.formData.title.length > 0) {
        self.title = self.viewModel.formData.title;
    }else {
        self.title = [MXBundleUtil localizedStringForKey:@"pre_chat_list_title"];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)dismiss {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)getHeaderMaxWidth {
    return self.tableView.viewWidth - 2 * kMXPreChatHeaderHorizontalSpacing;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.cacheHeaderView.viewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return self.cacheHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.formData.menu.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor mx_colorWithHexString:ebonyClay];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.viewModel.formData.menu.menuItems[indexPath.row] desc];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gotoFormViewControllerWithSelectedMenuIndexPath:indexPath animated:YES];
}

- (void)gotoFormViewControllerWithSelectedMenuIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    MXPreChatSubmitViewController *submitViewController = [MXPreChatSubmitViewController new];
    MXPreChatMenuItem *selectedMenu = self.viewModel.formData.menu.menuItems[indexPath.row];
    submitViewController.formData = self.viewModel.formData;
    submitViewController.completeBlock = self.completeBlock;
    if (indexPath) {
        submitViewController.selectedMenuItem = selectedMenu;
    }
    
    if (self.viewModel.formData.form.formItems.count == 0 || [self.viewModel.formData.form.status isEqualToString:@"close"]) {
        [self dismissViewControllerAnimated:YES completion:^{            
            if (self.completeBlock) {
                NSString *target = selectedMenu.target;
                NSString *targetType = selectedMenu.targetKind;
                self.completeBlock(@{@"target":target, @"targetType":targetType, @"menu":selectedMenu.desc});
            }
        }];
    } else {
        MXPreChatFormItem *item = self.viewModel.formData.form.formItems.count > 0 ? self.viewModel.formData.form.formItems.firstObject : nil;
        if ((self.viewModel.formData.form.formItems.count == 1 && [item isKindOfClass: MXPreChatFormItem.class] && [item.displayName isEqual:@"验证码"])) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.completeBlock) {
                    NSString *target = selectedMenu.target;
                    NSString *targetType = selectedMenu.targetKind;
                    self.completeBlock(@{@"target":target, @"targetType":targetType, @"menu":selectedMenu.desc});
                }
            }];
        } else {
            [self.navigationController pushViewController:submitViewController animated:animated];
        }
    }
}

-(UIView *)cacheHeaderView {
    if (!_cacheHeaderView) {
        MXPreChatTopView *topView;
        CGFloat topViewHeight = 0;

        if (self.viewModel.formData.content.length > 0) {
            topView = [[MXPreChatTopView alloc] initWithHTMLText:self.viewModel.formData.content maxWidth:[self getHeaderMaxWidth]];
            topViewHeight = [topView getTopViewHeight];
            topView.frame = CGRectMake(kMXPreChatHeaderHorizontalSpacing, 0, [self getHeaderMaxWidth], topViewHeight);
        }
        
        CGSize textSize = CGSizeMake([self getHeaderMaxWidth], MAXFLOAT);
        CGRect textRect = [self.viewModel.formData.menu.title boundingRectWithSize:textSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium]}
                                                     context:nil];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMXPreChatHeaderHorizontalSpacing, topViewHeight + kMXPreChatHeaderBottom, [self getHeaderMaxWidth], textRect.size.height)];
        titleLabel.text = self.viewModel.formData.menu.title;
        titleLabel.textColor = [UIColor mx_colorWithHexString:ebonyClay];
        titleLabel.font = [UIFont systemFontOfSize:16 weight: UIFontWeightMedium];
        
        _cacheHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.viewWidth, CGRectGetMaxY(titleLabel.frame) + kMXPreChatHeaderBottom)];
        [_cacheHeaderView addSubview:topView];
        [_cacheHeaderView addSubview:titleLabel];
    }
    return _cacheHeaderView;
}

@end
