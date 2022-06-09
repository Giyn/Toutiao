//
//  TTSliderNavView.m
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/8.
//

#import "TTSliderNavView.h"
#import "Masonry.h"


@interface TTSliderNavView ()
@end

@implementation TTSliderNavView
- (instancetype)initWithButtonTitles:(NSArray <NSString *> *)buttonTitles {
    self = [super init];
    if (self) {
        // 允许交互
        _canInteract = YES;
        // 初始化容器
        _container = UIScrollView.new;
        [self addSubview:_container];
        // 初始化按钮标题
        [self initButtonsWithTitles:buttonTitles];
        // 初始化滑块
        [self initSliderLabel];
        // 设置容器
        _container.showsHorizontalScrollIndicator = NO;
        _container.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
    return self;
}

// 初始化指示器滑块
- (void)initSliderLabel {
    _sliderLabel = UILabel.new;
    _sliderLabel.backgroundColor = UIColor.systemRedColor;
    // 圆角
    [_sliderLabel.layer setCornerRadius:2];
    [_sliderLabel setClipsToBounds:YES];
    [self.container addSubview:_sliderLabel];
}

// 遍历标题数组生成按钮初始化，并将按钮添加为容器子视图
- (void)initButtonsWithTitles:(NSArray <NSString *> *)buttonTitles {
    NSMutableArray <UIButton *> *tmpButtonArray = @[].mutableCopy;
    [buttonTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = UIButton.new;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:obj forState:UIControlStateNormal];
        // 设置按钮未选中状态
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        // 设置按钮选中状态
        [button setTitleColor:UIColor.redColor forState:UIControlStateSelected];
        [tmpButtonArray addObject:button];
        [_container addSubview:button];
        // tag添加偏移量1000
        [button setTag:idx + 1000];
    }];
    _buttonArray = [tmpButtonArray copy];
}

// 将根视图的buttonWithTag映射到容器的viewWithTag方法上，并对返回值进行类型转换
- (UIButton *)buttonWithTag:(NSInteger)tag {
    return (UIButton *)[_container viewWithTag:tag];
}

// 为子视图设置约束
- (void)setupSubViews {
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
    }];
    // 手动调用布局，否则下面约束无法添加
    [self layoutIfNeeded];
    // 单个按钮的长度
    CGFloat widthMetric = _container.frame.size.width / 3;
    // 遍历按钮数组添加约束
    [_buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_container).offset(widthMetric * idx);
                    make.height.mas_equalTo(_container);
                    make.width.mas_equalTo(widthMetric);
                    make.centerY.mas_equalTo(_container);
        }];
    }];
    // 计算左偏移量
    CGFloat paddingLeft = self.frame.size.width / 24;
    [_sliderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.height.mas_equalTo(4);
        make.width.mas_equalTo(self.frame.size.width / 4);
        make.left.mas_equalTo(paddingLeft);
    }];
    // 设置容器宽度为下挂按钮个数 * 按钮宽度，垂直方向置0关闭y轴手势监听
    _container.contentSize = CGSizeMake(4 * self.frame.size.width / 3, 0);
}

@end
