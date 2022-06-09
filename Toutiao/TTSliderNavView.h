//
//  TTSliderNavView.h
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSliderNavView : UIView
@property (nonatomic, strong) UIScrollView *container;/// 挂载子视图的容器
@property (nonatomic, strong) NSArray <UIButton *> *buttonArray;/// 标签页按钮
@property (nonatomic, strong) UILabel *sliderLabel; /// 滑块标识
@property (nonatomic, assign) BOOL canInteract; /// 用于防止动画过程中用户操作触发其他动画
@property (nonatomic, assign) BOOL isButtonClicked; /// 判断是否用户点击，若为NO则为滑动容器切换子视图
- (instancetype)initWithButtonTitles:(NSArray <NSString *> *)buttonTitles; /// 初始化时需要标签页按钮标题数组
- (UIButton *)buttonWithTag:(NSInteger)tag; /// 根据button对应tag从container获取对应button
- (void)setupSubViews; /// 暴露子视图布局方法，初始化后装载时调用
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
