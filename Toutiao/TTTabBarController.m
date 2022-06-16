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

@interface TTTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UIButton *uploadButton;

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
    attrs[NSForegroundColorAttributeName] = [UIColor redColor]; // 设置文字的前景色

    // 创建子控制器 - 主页
    OnPageEnter onPageEnter = ^(NSUInteger currentIndex, UIViewController *_Nullable currentVC) {
        if (!currentVC || ![currentVC isKindOfClass:TTPagerViewController.class]) {
            return;
        }
        TTPagerViewController *currentPagerViewController = (TTPagerViewController *)currentVC;
        [currentPagerViewController startPlayingCurrent];
    };
    OnPageLeave onPageLeave = ^(NSUInteger currentIndex, UIViewController *_Nullable currentVC) {
        if (!currentVC || ![currentVC isKindOfClass:TTPagerViewController.class]) {
            return;
        }
        TTPagerViewController *currentPagerViewController = (TTPagerViewController *)currentVC;
        [currentPagerViewController stopPlayingCurrent];
    };
    UIViewController *vcHomePage = [[TTPagerViewController alloc] initWithChildrenVCArray:@[TTVideoStreamController.new, TTVideoStreamController.new, TTVideoStreamController.new] titles:@[@"第一页", @"第二页", @"第三页"] showSearchBar:YES onPageLeave:onPageLeave onPageEnter:onPageEnter];
    UINavigationController *navcHomePage = [[UINavigationController alloc] initWithRootViewController:vcHomePage];
    vcHomePage.navigationController.navigationBar.hidden = YES;
    vcHomePage.tabBarItem.title = @"主页";
    vcHomePage.tabBarItem.image = [UIImage imageNamed:@"homepage"];
    UIImage *imageHomePage = [UIImage imageNamed:@"homepage_highlighted"];
    // 设置渲染模式 - 保持原始的渲染
    imageHomePage = [imageHomePage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vcHomePage.tabBarItem.selectedImage = imageHomePage;
    [vcHomePage.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];

    // 创建Navigation控制器 - 我的
    UINavigationController *navMine = UINavigationController.new;
    navMine.tabBarItem.title = @"我的";
    navMine.tabBarItem.image = [UIImage imageNamed:@"mine"];
    UIImage *imageMine = [UIImage imageNamed:@"mine_highlighted"];
    // 设置渲染模式 - 保持原始的渲染
    imageMine = [imageMine imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navMine.tabBarItem.selectedImage = imageMine;
    [navMine.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];

    navMine.navigationBar.tintColor = [UIColor colorNamed:@"tt_red"];
    
    [self addChildViewController:navcHomePage];
    [self addChildViewController:navMine];

    // 到时候把个人主页挂到这里
    navMine.viewControllers = @[TTLoginController.new];

    //tabBar上添加一个UIButton遮盖住中间的UITabBar
     self.uploadButton.frame = CGRectMake((self.tabBar.frame.size.width-self.tabBar.frame.size.height)/2, 5, self.tabBar.frame.size.height, self.tabBar.frame.size.height);
     [self.tabBar addSubview:self.uploadButton];

     self.delegate = self;
}

// 控制器代理方法
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    if ([viewController isKindOfClass:[UITableViewController class]]) {
        // 点击了中间的控制器
        [self uploadButtonAction];
        return NO;
    }
    return YES;
}

- (UIButton *)uploadButton {
    if (!_uploadButton) {
        _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_uploadButton setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];

        [_uploadButton addTarget:self action:@selector(uploadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadButton;
}

- (void)uploadButtonAction {
    NSLog(@"上传");
}


@end
