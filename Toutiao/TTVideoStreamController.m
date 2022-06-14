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

#define offsetY 100 // 位置：松开后切换视频

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
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);

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
        if (translatedPoint.y < -offsetY && self.currentIndex < (self.urlArray.count - 1)) {
            self.currentIndex++;
        }
        if (translatedPoint.y > offsetY && self.currentIndex > 0) {
            self.currentIndex--;
        }
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } completion:^(BOOL finished) {
            scrollView.panGestureRecognizer.enabled = YES;
        }];
    });
}

// 观察currentIndex变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentIndex"]) {
        // 整个列表视频播放，只会存在一个播放器
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

- (void)imglongTapClick:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"头条视频版" message:@"请选择您的操作" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *rate_0_5 = [UIAlertAction actionWithTitle:@"倍速播放: 0.5倍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.avPlayerView.player.rate = 0.5;
        }];
        UIAlertAction *rate_1_0 = [UIAlertAction actionWithTitle:@"倍速播放: 正常" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.avPlayerView.player.rate = 1.0;
        }];
        UIAlertAction *rate_1_5 = [UIAlertAction actionWithTitle:@"倍速播放: 1.5倍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.avPlayerView.player.rate = 1.5;
        }];
        UIAlertAction *rate_2_0 = [UIAlertAction actionWithTitle:@"倍速播放: 2倍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.avPlayerView.player.rate = 2.0;
        }];
        UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"保存视频");
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"取消");
        }];
        [sheet addAction:rate_0_5];
        [sheet addAction:rate_1_0];
        [sheet addAction:rate_1_5];
        [sheet addAction:rate_2_0];
        [sheet addAction:save];
        [sheet addAction:cancel];
        [self presentViewController:sheet animated:YES completion:nil];
    }
}


@end
