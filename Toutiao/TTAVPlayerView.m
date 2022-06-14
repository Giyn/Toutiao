//
//  TTAVPlayerView.m
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import "TTAVPlayerView.h"
#import "config.h"

@implementation TTAVPlayerView

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url image:(UIImage *)image {
    if (self = [super initWithFrame:frame]) {
        self.isFullScreen = NO;
        self.smallFrame = frame;
        self.bigFrame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);

        CGFloat height = frame.size.height;
        CGFloat width = frame.size.width;

        // 占位，视频第一帧图片
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height-kTabBarHeight)];
        bgImageView.image = image;
        bgImageView.userInteractionEnabled = YES;
        [self addSubview:bgImageView];

        // 网络视频路径
        NSURL *webVideoUrl = [NSURL URLWithString:url];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:webVideoUrl];
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];

        self.avLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.avLayer.backgroundColor = [UIColor blackColor].CGColor;
        self.avLayer.videoGravity = AVLayerVideoGravityResizeAspect; // 屏幕自适应
        self.avLayer.frame = CGRectMake(0, 0, bgImageView.frame.size.width, bgImageView.frame.size.height);
        [bgImageView.layer addSublayer:self.avLayer];

        self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, height-kTabBarHeight, width, 30)];
        self.sliderView.hidden = YES;
        [self addSubview:self.sliderView];

        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.sliderView.frame.size.height, width, 30)];
        self.bottomView.backgroundColor = [UIColor grayColor];
        self.bottomView.alpha = 0.6;
        [self.sliderView addSubview:self.bottomView];

        self.startVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.startVideoBtn.frame = CGRectMake(0, 0, 30, 30);
        [self.startVideoBtn setImage:[UIImage imageNamed:@"video_pause_btn"] forState:normal];
        [self.startVideoBtn addTarget:self action:@selector(actStartVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.startVideoBtn];

        self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 50, 50)];
        self.currentTimeLabel.textColor = [UIColor whiteColor];
        self.currentTimeLabel.text = @"00:00";
        self.currentTimeLabel.font = [UIFont systemFontOfSize:14];
        self.currentTimeLabel.textAlignment = 1;
        [self.bottomView addSubview:self.currentTimeLabel];

        self.slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 0, kScreenWidth-200, 50)];
        self.slider.minimumValue = 0;
        self.slider.minimumTrackTintColor = [UIColor whiteColor];
        self.slider.maximumTrackTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        [self.slider addTarget:self action:@selector(avSliderAction) forControlEvents:
        UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
        [self.slider setThumbImage:[UIImage imageNamed:@"slider"] forState:normal];
        [self.bottomView addSubview:self.slider];

        self.countTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.slider.frame), 0, 50, 50)];
        self.countTimeLabel.textColor = [UIColor whiteColor];
        self.countTimeLabel.text = @"00:00";
        self.countTimeLabel.font = [UIFont systemFontOfSize:14];
        self.countTimeLabel.textAlignment = 1;
        [self.bottomView addSubview:self.countTimeLabel];

        self.changeFullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeFullScreenBtn.frame = CGRectMake(CGRectGetMaxX(self.countTimeLabel.frame), 0, 50, 50);
        [self.changeFullScreenBtn setImage:[UIImage imageNamed:@"full_screen"] forState:normal];
        [self.changeFullScreenBtn addTarget:self action:@selector(actChange:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.changeFullScreenBtn];
        self.changeFullScreenBtn.selected = NO;

        WEAKBLOCK(self);

        [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {

            STRONGBLOCK(self);

            NSInteger currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
            NSInteger countTime = CMTimeGetSeconds(self.player.currentItem.duration);

            self.currentTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%zi",currentTime]];
            self.slider.value = currentTime;

            if (currentTime >= countTime) {
                self.slider.value = 0;
                [self.player seekToTime:CMTimeMake(0, 1)];
            }
        }];

        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

        UITapGestureRecognizer *hidenTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenBottonView:)];
        [self addGestureRecognizer:hidenTap];
    }
    
    // 添加观察者
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    // 主页点击searchbar时暂停视频
    [center addObserver:self selector:@selector(pause) name:@"searchBarClicked" object:nil];
    // 搜索页点击返回时继续播放视频
    [center addObserver:self selector:@selector(play) name:@"returnToHomepage" object:nil];
    [center addObserver:self selector:@selector(pause) name:@"backLastVC" object:nil];
    return self;
}

// 移除观察者
- (void)dealloc{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)hiddenBottonView: (UITapGestureRecognizer *)tap {
    if (self.sliderView.hidden) {
        self.sliderView.hidden = NO;
    } else {
        self.sliderView.hidden = YES;
    }
}

- (void)avSliderAction {
    CGFloat seconds = self.slider.value;
    [self startPlayer:seconds];
}

- (void)startPlayer:(CGFloat)seconds {
    CMTime startTime = CMTimeMakeWithSeconds(seconds, self.player.currentTime.timescale);
    [self.player seekToTime:startTime];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.avLayer.frame = self.bounds;
    self.sliderView.frame = self.bounds;

    CGFloat topY = !self.isFullScreen?0:0;

    CGFloat leftX = !self.isFullScreen?0:NavigationHeight;

    CGFloat spaceWidth = !self.isFullScreen?0:30;

    self.bottomView.frame = CGRectMake(0, self.sliderView.frame.size.height-topY-50, self.sliderView.frame.size.width, 50);

    self.startVideoBtn.frame = CGRectMake(leftX, 0, 50, 50);

    self.currentTimeLabel.frame = CGRectMake(leftX+50, 0, 50, 50);

    self.slider.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), 0, self.sliderView.frame.size.width-100-spaceWidth-CGRectGetMaxX(self.currentTimeLabel.frame), 50);

    self.countTimeLabel.frame = CGRectMake(self.sliderView.frame.size.width-100-spaceWidth, 0, 50, 50);

    self.changeFullScreenBtn.frame = CGRectMake(self.sliderView.frame.size.width-50-spaceWidth, 0, 50, 50);
}

// 观察currentIndex变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]){
        // 获取playerItem的status属性最新的状态
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:{
                NSInteger countTime = CMTimeGetSeconds(self.player.currentItem.duration);
                self.slider.maximumValue = countTime;
                self.countTimeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%zi", countTime]];
                [self.player play];
                break;
            }
            case AVPlayerStatusFailed:{ // 视频加载失败，点击重新加载
                break;
            }
            case AVPlayerStatusUnknown:{
                break;
            }
            default:
                break;
        }
    }
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)actStartVideo:(UIButton *)btn {
    if (!self.startVideoBtn.selected) {
        self.startVideoBtn.selected = YES;
        [self.startVideoBtn setImage:[UIImage imageNamed:@"video_play_btn"] forState:normal];
        [self pause];
    } else {
        self.startVideoBtn.selected = NO;
        [self.startVideoBtn setImage:[UIImage imageNamed:@"video_pause_btn"] forState:normal];
        [self play];
    }
}

- (void)actChange:(UIButton *)btn {
    if (!self.changeFullScreenBtn.selected) {
        self.isFullScreen = YES;
        self.changeFullScreenBtn.selected = YES;
        [self.changeFullScreenBtn setImage:[UIImage imageNamed:@"exit_full_screen"] forState:normal];

        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI / 2);
        } completion:nil];

        self.frame = self.bigFrame;

        if (self.changeScreen) {
            self.changeScreen(self.isFullScreen);
        }
    } else {
        self.changeFullScreenBtn.selected = NO;
        self.isFullScreen = NO;
        [self.changeFullScreenBtn setImage:[UIImage imageNamed:@"full_screen"] forState:normal];

        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI * 2);
        } completion:^(BOOL finished) {
            if (self.changeScreen) {
                self.changeScreen(self.isFullScreen);
            }
        }];
        self.frame = self.smallFrame;
    }
}

- (void)removePlayer {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player pause];
}

- (NSString *)getMMSSFromSS:(NSString *)totalTime {
    NSInteger seconds = [totalTime integerValue];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", seconds/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
    return format_time;
}


@end
