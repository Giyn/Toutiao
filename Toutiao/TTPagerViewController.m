//
//  TTPagerViewController.m
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/7.
//

#import "TTPagerViewController.h"
#import "TTSliderNavView.h"
#import "TTSearchViewController.h"
#import "TTVideoStreamController.h"
#import "TTAVPlayerView.h"
#import "Masonry.h"
NSInteger const kTagToIndex = 1000;
@interface TTPagerViewController () <UIScrollViewDelegate, UISearchBarDelegate>

@end

@implementation TTPagerViewController

- (instancetype)initWithChildrenVCArray:(NSArray<UIViewController *> *)childrenVCArray titles:(NSArray<NSString *> *)titles showSearchBar:(BOOL)showSearchBar onPageLeave:(OnPageLeave)onPageLeave onPageEnter:(OnPageEnter)onPageEnter {
    if (self) {
        _childrenVCArray = childrenVCArray;
        _showSearchBar = showSearchBar;
        if (_showSearchBar) {
            _searchBar = UISearchBar.new;
            if (@available(iOS 13.0, *)) {
                _searchBar.searchTextField.textColor = UIColor.whiteColor;
            } else {
                [_searchBar.subviews.firstObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([obj isKindOfClass:UITextField.class]) {
                                        UITextField *textField = obj;
                                        textField.textColor = UIColor.whiteColor;
                                        *stop = YES;
                                        return;
                                    }
                }];
            }
        }
        // 初始化按钮
        _ttSliderNav = [[TTSliderNavView alloc]initWithButtonTitles:titles];
        _onPageLeave = onPageLeave;
        _onPageEnter = onPageEnter;
    }
    return self;
}

- (instancetype)initWithChildrenVCArray:(NSArray <UIViewController *> *)childrenVCArray titles:(NSArray <NSString *> *)titles showSearchBar:(BOOL)showSearchBar __attribute__((unused)) {
    self = [super init];
    if (self) {
        _childrenVCArray = childrenVCArray;
        _showSearchBar = showSearchBar;
        if (_showSearchBar) {
            _searchBar = UISearchBar.new;
            if (@available(iOS 13.0, *)) {
                _searchBar.searchTextField.textColor = UIColor.whiteColor;
            } else {
                [_searchBar.subviews.firstObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:UITextField.class]) {
                        UITextField *textField = obj;
                        textField.textColor = UIColor.whiteColor;
                        *stop = YES;
                        return;
                    }
                }];
            }
        }
        // 初始化按钮
        _ttSliderNav = [[TTSliderNavView alloc]initWithButtonTitles:titles];
        _onPageLeave = ^(NSUInteger currentIndex, __weak UIViewController * _Nullable weakVC) {
            __strong typeof(weakVC) strongVC = weakVC;
            if (![strongVC isKindOfClass:TTPagerViewController.class]) {
                return;
            }
            TTPagerViewController *strongSelf = (TTPagerViewController *)strongVC;
            UIViewController *currentVC = strongSelf.childrenVCArray[currentIndex];
            if ([currentVC isKindOfClass:TTVideoStreamController.class]) {
                TTVideoStreamController *currentVideoStreamVC = (TTVideoStreamController *)currentVC;
                TTAVPlayerView *ttAVPlayerView = [currentVideoStreamVC valueForKey:@"avPlayerView"];
                [ttAVPlayerView pause];
            }
        };
        _onPageEnter = ^(NSUInteger currentIndex, __weak UIViewController * _Nullable weakVC) {
            __strong typeof(weakVC) strongVC = weakVC;
            if (![strongVC isKindOfClass:TTPagerViewController.class]) {
                return;
            }
            TTPagerViewController *strongSelf = (TTPagerViewController *)strongVC;
            UIViewController *currentVC = strongSelf.childrenVCArray[currentIndex];
            if ([currentVC isKindOfClass:TTVideoStreamController.class]) {
                TTVideoStreamController *currentVideoStreamVC = (TTVideoStreamController *)currentVC;
                TTAVPlayerView *ttAVPlayerView = [currentVideoStreamVC valueForKey:@"avPlayerView"];
                [ttAVPlayerView play];
            }
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpContainer];
    [self.view addSubview:_container];
    [self.view addSubview:_ttSliderNav];
    // 初始化容器下视图
    [self addChildrenViewToContainerWithIndex:0];
    // 初始化容器滚动宽度，禁用y轴手势
    CGSize contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width * _childrenVCArray.count, 0);
    [_container setContentSize:contentSize];
    // 添加搜索框
    if (_showSearchBar) {
        [self.view addSubview: _searchBar];
        // 初始化搜索框，设置安全区域边距
        [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.view);
            make.height.mas_equalTo(50);
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        // 设置搜索框代理
        _searchBar.delegate = self;
    }
    // 初始化指示器滑块约束
    [_ttSliderNav mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_showSearchBar) {
            make.top.mas_equalTo(_searchBar.mas_bottom);
            make.width.mas_equalTo(_searchBar.mas_width).offset(-40);
            make.centerX.mas_equalTo(_searchBar);
            make.height.mas_equalTo(_searchBar);
        } else {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.width.mas_equalTo(self.view.mas_width).offset(-40);
            make.centerX.mas_equalTo(self.view);
            make.height.mas_equalTo(50);
        }
    }];
    // 初始化选中第一个按钮
    [_ttSliderNav.buttonArray.firstObject setSelected:YES];
    // 绑定点击事件
    [_ttSliderNav.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside];
    }];
    [_ttSliderNav setupSubViews];
}

- (void)populateWithChildren:(NSArray<UIView *> *)children __attribute__((unused)) {
    // 遍历children数组添加视图到滑动容器
    __block BOOL containsNilObj = NO;
    [children enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == nil) {
            containsNilObj = YES;
            *stop = YES;
            return;
        }
        [self.container addSubview:obj];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(UIScreen.mainScreen.bounds.size.width * idx);
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(self.container);
        }];
    }];
    NSAssert(containsNilObj == NO, @"Error: 子视图不能为空指针");
}

- (void)addChildrenViewToContainerWithIndex:(NSUInteger)idx {
    // 将对应下标VC视图添加到滑动容器
    UIView *view = _childrenVCArray[idx].view;
    if (view.superview == nil) {
        [_container addSubview:_childrenVCArray[idx].view];
        [_childrenVCArray[idx].view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(UIScreen.mainScreen.bounds.size.width * idx);
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(self.container);
        }];
    }
}

// 初始化容器
- (void)setUpContainer {
    _container = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _container.bounces = 0;
    _container.showsHorizontalScrollIndicator = NO;
    _container.delegate = self;
    _container.pagingEnabled = YES;
}

// 按钮绑定的滑动事件
- (void)sliderAction:(UIButton *)sender {
    NSInteger nextIndex = [self indexFromTag:sender.tag];
    // 判断重复选中或者正在动画状态，直接返回
    if (_currentIndex == nextIndex || !_ttSliderNav.canInteract) {
        return;
    }
    // 取消先前激活按钮
    UIButton *currentSelectedButton = [_ttSliderNav buttonWithTag: [self tagFromIndex:_currentIndex]];
    NSLog(@"%@", currentSelectedButton.description);
    [currentSelectedButton setSelected:NO];
    [self animateWithTag:sender.tag];
    // 设置为按钮点击状态，防止动画冲突
    _ttSliderNav.isButtonClicked = YES;
    // 容器滚动动画
    [UIView animateWithDuration:0.3 animations:^{
        self->_container.contentOffset = CGPointMake(UIScreen.mainScreen.bounds.size.width*(nextIndex), 0);
    } completion:^(BOOL finished) {
        // 释放按钮点击状态
        self->_ttSliderNav.isButtonClicked = NO;
    }];
}

// 根据激活事件按钮tag更新约束添加动画
- (void)animateWithTag:(NSInteger)tag {
    // 按钮宽度
    CGFloat widthMetric = _ttSliderNav.frame.size.width / 3;
    // sliderNav容器宽度
    CGFloat sliderWidth = _ttSliderNav.sliderLabel.frame.size.width;
    // 滑动指示器
    UILabel *sliderLabel = self->_ttSliderNav.sliderLabel;
    UIScrollView *sliderContainer = _ttSliderNav.container;
    // 禁止动画结束前交互
    _ttSliderNav.canInteract = false;
    [UIView animateWithDuration:0.3 animations:^{
        [sliderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left
                .mas_equalTo(sliderContainer.mas_left)
                .offset((widthMetric - sliderWidth)/2 + ([self indexFromTag:tag]) * widthMetric);
        }];
        // 手动提示sliderNav父视图重新布局，否则动画不会生效
        [self->_ttSliderNav layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 允许用户交互
        self->_ttSliderNav.canInteract = YES;
    }];
    // 选中对应按钮
    [[_ttSliderNav buttonWithTag:tag]setSelected:YES];
    NSLog(@"scroll end: %zd", _currentIndex);
    // 更新下标
    NSUInteger nextIndex = [self indexFromTag:tag];
    NSUInteger currentIdx = _currentIndex;
    __weak typeof(self) weakSelf = self;
    if (_onPageLeave) {
        _onPageLeave(currentIdx, weakSelf);
    }
    _currentIndex = nextIndex;
    if (_onPageEnter) {
        _onPageEnter(nextIndex, weakSelf);
    }
    [self addChildrenViewToContainerWithIndex:nextIndex];
}

#pragma mark - ScrollView委托方法

// 监听滑动事件开始，激活约束使sliderNav下指示器根据滑动滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 若为按钮点击引起的滑动，则直接返回
    if (_ttSliderNav.isButtonClicked) {
        return;
    }
    // 计算当前slider偏移量
    CGFloat currentOffSetX = _container.contentOffset.x;
    CGFloat sliderOffsetX = currentOffSetX / 3.333 ;
    // 更新约束，使slider同步容器滚动
    [_ttSliderNav.sliderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_ttSliderNav.container.mas_left).offset(sliderOffsetX + _ttSliderNav.bounds.size.width / 24);
    }];
    // 通知sliderNav的容器重新布局
    [_ttSliderNav.container layoutIfNeeded];
}

// 监听滚动事件结束减速（真正停止）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 拿到上一个页面下表对应按钮tag
    NSInteger previousTag = [self tagFromIndex:_currentIndex];
    // 取消激活
    [[_ttSliderNav buttonWithTag:previousTag]setSelected:NO];
    // 根据容器滑动偏移量计算下一个页面对应的按钮tag
    NSInteger nextTag = [self tagFromIndex:(NSUInteger) (scrollView.contentOffset.x / UIScreen.mainScreen.bounds.size.width)];
    // 开始动画
    [self animateWithTag:nextTag];
}

#pragma mark - 转换tag和index
- (NSUInteger)indexFromTag:(NSInteger)tag {
    return (NSUInteger) (tag - kTagToIndex);
}

- (NSInteger)tagFromIndex:(NSUInteger)index {
    return index + kTagToIndex;
}

#pragma mark - searchBar代理方法

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    // 发送通知 点击searchbar时暂停视频
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"searchBarClicked" object:nil];
    
    return YES;
}

// 点击键盘搜索键后跳转到搜索页面
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    // 收起键盘
    [self.searchBar resignFirstResponder];
    // 页面跳转
    TTSearchViewController * searchVC = [[TTSearchViewController alloc] initWithText:self.searchBar.text];
    [self.navigationController pushViewController:searchVC animated:YES];
}

@end
