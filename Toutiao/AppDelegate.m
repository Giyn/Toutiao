//
//  AppDelegate.m
//  Toutiao
//
//  Created by Admin on 2022/6/5.
//

#import "AppDelegate.h"
#import "TTVideoStreamController.h"
#import "TTTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

    // 设置控制器为window的根控制器
    self.window.rootViewController = [[TTTabBarController alloc] init];

    return YES;
}


@end
