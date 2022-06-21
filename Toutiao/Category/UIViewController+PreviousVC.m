//
//  UINavigationController+PreviousVC.m
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "UIViewController+PreviousVC.h"

@implementation UIViewController (PreviousVC)
- (UIViewController *)getPreviousVC {
    UINavigationController *navVC = self.navigationController;
    if (navVC == nil) {
        return nil;
    }
    __block NSUInteger currentVCIndex;
    [navVC.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqual:self]) {
                currentVCIndex = idx;
                *stop = YES;
                return;
            }
    }];
    if (currentVCIndex == 0) {
        return nil;
    }
    return navVC.viewControllers[currentVCIndex-1];
}
@end
