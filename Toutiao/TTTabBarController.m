//
//  TTTabBarController.m
//  Toutiao
//
//  Created by Admin on 2022/6/9.
//

#import "MJExtension.h"
#import "TTTabBarController.h"
#import "TTWorksListController.h"
#import "TTLoginController.h"
#import "TTPagerViewController.h"
#import "TTNetworkTool.h"
#import "TTTypeListResponse.h"
#import "TTHomePageLoadingViewController.h"
#import "URLs.h"

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
        [currentPagerViewController stopPlayingCurrentWithPlayerRemoved: YES];
    };
    
    TTNetworkTool *tool = [TTNetworkTool sharedManager];
    
    UIViewController *loadingPage = TTHomePageLoadingViewController.new;
    
    // 创建Navigation控制器 - 主页
    UINavigationController *navHomePage = [[UINavigationController alloc] initWithRootViewController:loadingPage];
    navHomePage.navigationBar.hidden = YES;
    navHomePage.tabBarItem.title = @"主页";
    navHomePage.tabBarItem.image = [UIImage imageNamed:@"homepage"];
    UIImage *imageHomePage = [UIImage imageNamed:@"homepage_highlighted"];
    // 设置渲染模式 - 保持原始的渲染
    imageHomePage = [imageHomePage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navHomePage.tabBarItem.selectedImage = imageHomePage;
    [navHomePage.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];
    navHomePage.navigationBar.tintColor = [UIColor colorNamed:@"tt_red"];
    
    [tool requestWithMethod:TTHttpMethodTypeGET path:getTypeListPath params:@{} requiredToken:NO onSuccess:^(id  _Nonnull responseObject) {
        TTTypeListResponse *typeListResponse = [TTTypeListResponse mj_objectWithKeyValues:responseObject];
        NSArray <NSString *> *types = typeListResponse.data;
        NSMutableArray <TTWorksListController *> *childrenArray = @[].mutableCopy;
        for (NSString *type in types) {
            TTWorksListController *childVC = TTWorksListController.new;
            childVC.type = type;
            [childrenArray addObject:childVC];
        }
        UIViewController *vcHomePage = [[TTPagerViewController alloc] initWithChildrenVCArray:childrenArray.copy titles:typeListResponse.data showSearchBar:YES onPageLeave:onPageLeave onPageEnter:onPageEnter];
            vcHomePage.navigationController.navigationBar.hidden = YES;
            [navHomePage pushViewController:vcHomePage animated:NO];
        } onError:^(NSError * _Nonnull error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } onProgress:nil];
    
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
    
    [self addChildViewController:navHomePage];
    [self addChildViewController:navMine];

    // 个人主页
    navMine.viewControllers = @[TTLoginController.new];

    //tabBar上添加一个UIButton遮盖住中间的UITabBar
    self.uploadButton.frame = CGRectMake((self.tabBar.frame.size.width-self.tabBar.frame.size.height)/2, 1, self.tabBar.frame.size.height, self.tabBar.frame.size.height);
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
