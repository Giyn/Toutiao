//
//  TTVideoStreamController.m
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import "TTVideoStreamController.h"
#import "TTVideoStreamCell.h"
#import "TTAVPlayerView.h"
#import <Foundation/Foundation.h>
#import "config.h"

@interface TTVideoStreamController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *videoImgArray; // 视频第一帧图片
@property (nonatomic, strong) NSArray *urlArray; // 存放视频url
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TTAVPlayerView *avPlayerView; // 视频播放器视图
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath

@end

@implementation TTVideoStreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupView];

    // 获取视频第一帧
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < self.urlArray.count; i++) {
            UIImage *image = [self getVideoPreViewImage:[NSURL URLWithString:self.urlArray[i]]];
            if (image != nil) {
                [self.videoImgArray replaceObjectAtIndex:i withObject:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    });
}

- (void)initData {
    self.urlArray = @[
        @"https://aweme.snssdk.com/aweme/v1/play/?video_id=ba8f4ff0c1fe445dbfdc1cc9565222fa&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0",
        @"https://v-cdn.zjol.com.cn/276994.mp4",
        @"https://v-cdn.zjol.com.cn/276991.mp4",
        @"https://v-cdn.zjol.com.cn/276986.mp4",
        @"https://v-cdn.zjol.com.cn/276990.mp4",
        @"https://v-cdn.zjol.com.cn/276996.mp4",
        @"https://v-cdn.zjol.com.cn/277000.mp4",
        @"https://v-cdn.zjol.com.cn/277001.mp4",
        @"https://v-cdn.zjol.com.cn/277003.mp4",
        @"https://v-cdn.zjol.com.cn/280443.mp4",
        @"https://v-cdn.zjol.com.cn/276982.mp4"
    ];

    self.videoImgArray = [NSMutableArray array];
    for (int i = 0; i < self.urlArray.count; i++) {
        [self.videoImgArray addObject:[UIImage imageNamed:@"video_loading"]];
    }
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = self.tableView.frame.size.height;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.scrollsToTop = NO;

    if (@available(ios 11.0,*)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[TTVideoStreamCell class] forCellReuseIdentifier:@"TTVideoStreamCell"];
    
    // 创建长按手势
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imglongTapClick:)];
    [self.view addGestureRecognizer:longTap];
    
    // 添加观察者
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    });
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urlArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTVideoStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TTVideoStreamCell" forIndexPath:indexPath];
    // 显示视频第一帧图片
    cell.bgImageView.image = self.videoImgArray[indexPath.row];
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        scrollView.panGestureRecognizer.enabled = NO;
        if (translatedPoint.y < -100 && self.currentIndex < (self.urlArray.count - 1)) {
            self.currentIndex++;
        }
        if (translatedPoint.y > 100 && self.currentIndex > 0) {
            self.currentIndex--;
        }
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
            // 滑动到指定cell
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } completion:^(BOOL finished) {
            // 可以响应其他手势
            scrollView.panGestureRecognizer.enabled = YES;
        }];
    });
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentIndex"]) {
        TTVideoStreamCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];

        [self.avPlayerView removePlayer];
        [self.avPlayerView removeFromSuperview];
        self.avPlayerView = [[TTAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.tableView.rowHeight-kTabBarHeight) url:self.urlArray[self.currentIndex] image:self.videoImgArray[self.currentIndex]];
        [cell.contentView addSubview:self.avPlayerView];
        [cell insertSubview:cell.middleView belowSubview:self.avPlayerView];

        WEAKBLOCK(self);

        self.avPlayerView.changeScreen = ^(BOOL isFull) {
            STRONGBLOCK(self);
            cell.bgImageView.hidden = YES;
            if (isFull) {
                self.tabBarController.tabBar.hidden = YES;
                self.tableView.scrollEnabled = NO;
                cell.middleView.hidden = YES;
            } else {
                self.tabBarController.tabBar.hidden = NO;
                self.tableView.scrollEnabled = YES;
                cell.middleView.hidden = NO;
                cell.bgImageView.hidden = NO;
            }
        };
    }
}

// 获取网络视频第一帧
- (UIImage*)getVideoPreViewImage:(NSURL *)path {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0, 1);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

// 长按加速播放，释放后恢复
- (void)imglongTapClick:(UILongPressGestureRecognizer *)gesture {
    if (self.avPlayerView.startVideoBtn.selected == NO) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            self.avPlayerView.player.rate = 2.0;
        } else {
            self.avPlayerView.player.rate = 1.0;
        }
    }
}


@end
