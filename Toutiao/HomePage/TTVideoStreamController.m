//
//  TTVideoStreamController.m
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <MJExtension/NSObject+MJKeyValue.h>
#import "TTVideoStreamController.h"
#import "TTVideoStreamCell.h"
#import "TTAVPlayerView.h"
#import "TTVideo.h"
#import "TTVideoStreamRequest.h"
#import "TTVideoStreamResponse.h"
#import "ShortMediaResourceLoader.h"
#import "config.h"

@interface TTVideoStreamController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<TTVideo *> *data; // 存放视频数据
@property (nonatomic, strong) NSMutableArray *urls; // 存放视频url
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TTAVPlayerView *avPlayerView; // 视频播放器视图
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath

@end

@implementation TTVideoStreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [NSMutableArray<TTVideo *> arrayWithCapacity:10];
    self.urls = [NSMutableArray arrayWithCapacity:10];
    [self loadData:1 size:10];
    [self setupView];
    [[ShortMediaManager shareManager] resetPreloadingWithMediaUrls:self.urls];
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

    if (@available(ios 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }

    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[TTVideoStreamCell class] forCellReuseIdentifier:@"TTVideoStreamCell"];

    // 创建长按手势
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imglongTapClick:)];
    [self.view addGestureRecognizer:longTap];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTVideoStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TTVideoStreamCell" forIndexPath:indexPath];
    // 显示视频封面
    cell.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSString *cover_url = [NSString stringWithFormat:@"http://47.96.114.143:62318/api/file/download/%@", self.data[self.currentIndex].pictureToken];
    UIImage *cover;
    NSData *cover_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]];
    cover = [UIImage imageWithData:cover_data];
    cell.bgImageView.image = cover;
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        scrollView.panGestureRecognizer.enabled = NO;
        if (translatedPoint.y < -100 && self.currentIndex < (self.data.count - 1)) {
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
            scrollView.panGestureRecognizer.enabled = YES;
        }];
    });
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentIndex"] && (self.currentIndex < self.data.count)) {
        TTVideoStreamCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];

        [self.avPlayerView removePlayer];
        [self.avPlayerView removeFromSuperview];

        NSString *video_url = [NSString stringWithFormat:@"http://47.96.114.143:62318/api/file/download/%@", self.data[self.currentIndex].videoToken];
        NSString *cover_url = [NSString stringWithFormat:@"http://47.96.114.143:62318/api/file/download/%@", self.data[self.currentIndex].pictureToken];
        UIImage *cover;
        NSData *cover_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]];
        cover = [UIImage imageWithData:cover_data];

        self.avPlayerView = [[TTAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.tableView.rowHeight-kTabBarHeight) url:video_url image:cover user:self.data[self.currentIndex].uploader title:self.data[self.currentIndex].name];
        [cell.contentView addSubview:self.avPlayerView];

        WEAKBLOCK(self);
        self.avPlayerView.changeScreen = ^(BOOL isFull) {
            STRONGBLOCK(self);
            cell.bgImageView.hidden = YES;
            if (isFull) {
                self.tabBarController.tabBar.hidden = YES;
                self.tableView.scrollEnabled = NO;
            } else {
                self.tabBarController.tabBar.hidden = NO;
                self.tableView.scrollEnabled = YES;
                cell.bgImageView.hidden = NO;
            }
        };
    }
}

#pragma mark - load data
- (void)loadData:(NSInteger)current size:(NSInteger)size {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://47.96.114.143:62318/api/works/getWorksList" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TTVideoStreamResponse *videoStreamResponse = [TTVideoStreamResponse mj_objectWithKeyValues:responseObject];
        for (NSDictionary *dict in videoStreamResponse.data.records) {
            TTVideo *video = [TTVideo mj_objectWithKeyValues:dict];
            [self.urls addObject:[NSString stringWithFormat:@"http://47.96.114.143:62318/api/file/download/%@", video.videoToken]];
            [self.data addObject:video];
        }
        [self.tableView reloadData];
        // 添加观察者
        [self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败: %@", error);
    }];
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
