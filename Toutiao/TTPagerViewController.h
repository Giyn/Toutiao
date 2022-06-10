//
//  TTPagerViewController.h
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/7.
//

#import <UIKit/UIKit.h>
/// Class forward declaration -- 参见<<Effective Objective-C 2.0>>
@class TTSliderNavView;
NS_ASSUME_NONNULL_BEGIN

@interface TTPagerViewController : UIViewController
@property (nonatomic, strong) UIScrollView *container; /// 下挂视图容器
@property (nonatomic, assign) NSInteger currentIndex; /// 记录当前页面位置
@property (nonatomic, strong) UISearchBar *searchBar; /// self.view下搜索框
@property (nonatomic, strong) TTSliderNavView *ttSliderNav; /// self.view下滑动指示器
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithChildrenArray:(NSArray <UIView *> *)childrenArray titles:(NSArray <NSString *> *)titles;
- (instancetype)initWithChildrenVCArray:(NSArray <UIViewController *> *)childrenVCArray titles:(NSArray <NSString *> *)titles;
@end

NS_ASSUME_NONNULL_END
