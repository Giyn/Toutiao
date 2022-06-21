//
//  TTPagerViewController.h
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/7.
//

#import <UIKit/UIKit.h>
/// Class forward declaration -- 参见<<Effective Objective-C 2.0>>
@class TTSliderNavView;
typedef void(^OnPageLeave)(NSUInteger currentIndex, UIViewController * _Nullable currentVC);
typedef void(^OnPageEnter)(NSUInteger currentIndex, UIViewController * _Nullable currentVC);
NS_ASSUME_NONNULL_BEGIN

@interface TTPagerViewController : UIViewController
@property (nonatomic, strong) NSArray <UIViewController *> *childrenVCArray; // 强持有子VC数组
@property (nonatomic, strong) UIScrollView *container; /// 下挂视图容器
@property (nonatomic, assign) NSUInteger currentIndex; /// 记录当前页面位置
@property (nonatomic, strong) UISearchBar *searchBar; /// self.view下搜索框
@property (nonatomic, assign) BOOL showSearchBar;
@property (nonatomic, strong) TTSliderNavView *ttSliderNav; /// self.view下滑动指示器
@property (nonatomic, strong) OnPageLeave onPageLeave; /// 页面换出回调
@property (nonatomic, strong) OnPageEnter onPageEnter; /// 页面换入回调
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithChildrenVCArray:(NSArray <UIViewController *> *)childrenVCArray titles:(NSArray <NSString *> *)titles showSearchBar:(BOOL)showSearchBar __attribute__((unused));
- (instancetype)initWithChildrenVCArray:(NSArray <UIViewController *> *)childrenVCArray titles:(NSArray <NSString *> *)titles showSearchBar:(BOOL)showSearchBar onPageLeave:(OnPageLeave)onPageLeave onPageEnter:(OnPageEnter)onPageEnter;
- (void)startPlayingCurrent;
- (void)stopPlayingCurrentWithPlayerRemoved:(BOOL)removePlayer;
@end

NS_ASSUME_NONNULL_END
