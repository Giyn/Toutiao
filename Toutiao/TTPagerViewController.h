//
//  TTPagerViewController.h
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/7.
//

#import <UIKit/UIKit.h>
/// Class forward declaration -- 参见<<Effective Objective-C 2.0>>
@class TTSliderNavView;
typedef void(^OnPageLeave)(NSUInteger currentIndex, __weak UIViewController *_Nullable weakVC);
typedef void(^OnPageEnter)(NSUInteger currentIndex, __weak UIViewController *_Nullable weakVC);
NS_ASSUME_NONNULL_BEGIN

@interface TTPagerViewController : UIViewController
@property (nonatomic, strong) NSArray <UIViewController *> *childrenVCArray; // 强持有子VC数组
@property (nonatomic, strong) UIScrollView *container; /// 下挂视图容器
@property (nonatomic, assign) NSUInteger currentIndex; /// 记录当前页面位置
@property (nonatomic, strong) UISearchBar *searchBar; /// self.view下搜索框
@property (nonatomic, assign) BOOL showSearchBar;
@property (nonatomic, strong) TTSliderNavView *ttSliderNav; /// self.view下滑动指示器
@property (nonatomic, strong) OnPageLeave onPageLeave; /// 页面切换回调
@property (nonatomic, strong) OnPageEnter onPageEnter; /// 页面进入回调
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithChildrenVCArray:(NSArray <UIViewController *> *)childrenVCArray titles:(NSArray <NSString *> *)titles showSearchBar:(BOOL)showSearchBar __attribute__((unused));
- (instancetype)initWithChildrenVCArray:(NSArray <UIViewController *> *)childrenVCArray titles:(NSArray <NSString *> *)titles showSearchBar:(BOOL)showSearchBar onPageLeave:(OnPageLeave)onPageLeave onPageEnter:(OnPageEnter)onPageEnter;
@end

NS_ASSUME_NONNULL_END
