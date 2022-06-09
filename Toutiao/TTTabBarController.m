//
//  TTTabBarController.m
//  Toutiao
//
//  Created by Admin on 2022/6/9.
//

#import "TTTabBarController.h"
#import "TTVideoStreamController.h"
#import "TTLoginController.h"
#import "TTPagerViewController.h"

@interface TTTabBarController ()

@end

@implementation TTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
}

- (void)setupView {
    // 设置文字属性
    NSMutableDictionary * attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:14.0];
    // 设置文字的前景色
    attrs[NSForegroundColorAttributeName] = [UIColor redColor];

    // 创建子控制器 - 主页
    UIViewController *vcHomePage = [[TTPagerViewController alloc] initWithChildrenVCArray:@[TTVideoStreamController.new, TTVideoStreamController.new, TTVideoStreamController.new] titles:@[@"第一页", @"第二页", @"第三页"]];
    vcHomePage.tabBarItem.title = @"主页";
    vcHomePage.tabBarItem.image = [UIImage imageNamed:@"homepage"];
    UIImage *imageHomePage = [UIImage imageNamed:@"homepage_highlighted"];
    // 设置渲染模式 - 保持原始的渲染
    imageHomePage = [imageHomePage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vcHomePage.tabBarItem.selectedImage = imageHomePage;
    [vcHomePage.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];

    UIViewController *vcUpload = [[UIViewController alloc] init];
    vcUpload.tabBarItem.title = @"上传";
    vcUpload.tabBarItem.image = [UIImage imageNamed:@"upload"];
    UIImage *imageUpload = [UIImage imageNamed:@"upload_highlighted"];
    // 设置渲染模式 - 保持原始的渲染
    imageUpload = [imageUpload imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vcUpload.tabBarItem.selectedImage = imageUpload;
    [vcUpload.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];

    // 创建Navigation控制器 - 我的
    UINavigationController *navMine = UINavigationController.new;
    navMine.tabBarItem.title = @"我的";
    navMine.tabBarItem.image = [UIImage imageNamed:@"mine"];
    UIImage *imageMine = [UIImage imageNamed:@"mine_highlighted"];
    // 设置渲染模式 - 保持原始的渲染
    imageMine = [imageMine imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navMine.tabBarItem.selectedImage = imageMine;
    [navMine.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];
    
    [self addChildViewController:vcHomePage];
    [self addChildViewController:vcUpload];
    [self addChildViewController:navMine];
    
    // 到时候把个人主页挂到这里
    navMine.viewControllers = @[TTLoginController.new];
}


@end
