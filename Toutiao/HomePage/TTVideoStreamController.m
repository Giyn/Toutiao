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
#import "config.h"

@interface TTVideoStreamController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<TTVideo *> *data; // 存放视频数据
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TTAVPlayerView *avPlayerView; // 视频播放器视图
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath

@end

@implementation TTVideoStreamController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData:1 size:10];
    [self setupView];
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
    
    // 添加观察者
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    });
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
        NSString *video_url = [NSString stringWithFormat:@"http://47.96.114.143:62318/api/file/download/%@", self.data[self.currentIndex].videoToken];
        NSString *cover_url = [NSString stringWithFormat:@"http://47.96.114.143:62318/api/file/download/%@", self.data[self.currentIndex].pictureToken];
        UIImage *cover;
        NSData *cover_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]];
        cover = [UIImage imageWithData:cover_data];
        self.avPlayerView = [[TTAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.tableView.rowHeight-kTabBarHeight) url:video_url image:cover];
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

#pragma mark - load data
- (void)loadData:(NSInteger)current size:(NSInteger)size {
    TTVideoStreamRequest *request = [[TTVideoStreamRequest alloc] init];
    request.current = current;
    request.size = size;

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://47.96.114.143:62318/api/works/getWorksList" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TTVideoStreamResponse *videoStreamResponse = [TTVideoStreamResponse mj_objectWithKeyValues:responseObject];
        for (NSDictionary *dict in videoStreamResponse.data.records) {
            TTVideo *video = [TTVideo mj_objectWithKeyValues:dict];
            NSLog(@"%@", video.videoToken);
            [self.data addObject:video];
            NSLog(@"%@", self.data);
        }
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
