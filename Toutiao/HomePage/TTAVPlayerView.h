//
//  TTAVPlayerView.h
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "ShortMediaResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTAVPlayerView : UIView

@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *countTimeLabel;
@property (nonatomic, strong) UIButton *startVideoBtn;
@property (nonatomic, strong) UIButton *changeFullScreenBtn;
@property (nonatomic, strong) AVPlayer *player; // 播放器对象
@property (nonatomic, strong) AVPlayerLayer *avLayer; // 展示播放View
@property (nonatomic, strong) UILabel *currentTimeLabel; // 当前倒计时
@property (nonatomic, strong) UISlider *slider; // 进度条
@property (nonatomic, assign) BOOL isFullScreen; // 是否全屏状态 默认NO
@property (nonatomic, assign) CGRect smallFrame; // 小屏幕frame
@property (nonatomic, assign) CGRect bigFrame; // 全屏frame
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) ShortMediaResourceLoader *resourceLoader;

// 点击全屏，取消全屏回调
@property (nonatomic, copy) void(^changeScreen) (BOOL isFull);

// 真实项目中，直接用dict包裹入参
- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url image:(UIImage *)image user:(NSString *)user title:(NSString *)title;

// 开始播放
- (void)play;

// 暂停
- (void)pause;

// 移除观察者
- (void)removePlayer;

@end

NS_ASSUME_NONNULL_END
