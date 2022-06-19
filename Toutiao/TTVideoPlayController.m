//
//  TTVideoPlayController.m
//  Toutiao
//
//  Created by luo on 2022/6/18.
//

#import "TTVideoPlayController.h"
#import "TTVideoStreamCell.h"
#import "TTAVPlayerView.h"
#import <Foundation/Foundation.h>
#import "config.h"
#import "TTSearchModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"

@interface TTVideoPlayController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) NSArray *searchModelArray;   //搜索得到的模型数组
@property (nonatomic, assign) NSInteger current;

@end

@implementation TTVideoPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.current = 0;
    [self loadData];
    
    // 返回键
    self.backBtn = [[UIButton alloc] init];
    [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.backBtn setTitleColor:[UIColor colorNamed:@"tt_red"] forState:UIControlStateNormal];
    [self.view addSubview:self.backBtn];
    if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20){
        self.backBtn.frame = CGRectMake(8, 48, 40, 20);
    }else{
        self.backBtn.frame = CGRectMake(8, 24, 40, 20);
    }
    [self.backBtn addTarget:self action:@selector(backLastVC) forControlEvents:UIControlEventTouchUpInside];
    
    // 上滑加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [footer setTitle:@"加载更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}

// 搜索页创建该vc时有返回功能
- (void)backLastVC{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"backLastVC" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - 数据处理
- (void) loadData{
    [self.tableView.mj_footer resetNoMoreData];
    
    [TTSearchModel searchModelWithSuccess:^(NSArray * _Nonnull array) {
        self.searchModelArray = array;
        self.current++;
        
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    } text:self.searchText current:[NSNumber numberWithInt:(int)(self.current+1)]];
}

- (void) setSearchModelArray:(NSArray *)searchModelArray{
    _searchModelArray = searchModelArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self willChangeValueForKey:@"currentIndex"];
        [self didChangeValueForKey:@"currentIndex"];
    });
    [self.tableView.mj_footer endRefreshing];
    if (self.searchModelArray.count < 10){
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu",self.searchModelArray.count);
    return self.searchModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTVideoStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TTVideoStreamCell" forIndexPath:indexPath];
    // 显示视频第一帧图片
    cell.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    // cell.bgImageView.image = self.videoImgArray[indexPath.row];
    TTSearchModel *model = self.searchModelArray[indexPath.row];
    [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:model.videoImg]];
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        scrollView.panGestureRecognizer.enabled = NO;
        if (translatedPoint.y < -100 && self.currentIndex < (self.searchModelArray.count - 1)) {
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
    if ([keyPath isEqualToString:@"currentIndex"] && (self.currentIndex < self.searchModelArray.count)) {
        TTVideoStreamCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];

        [self.avPlayerView removePlayer];
        [self.avPlayerView removeFromSuperview];
        
        // 创建avplayerView
        TTSearchModel *model = self.searchModelArray[self.currentIndex];
        self.avPlayerView = [[TTAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.tableView.rowHeight-kTabBarHeight) url:model.video image:[self getImageFromURL:model.videoImg]];
        
        // 设置显示的用户名和视频标题
        self.avPlayerView.userLabel.text = model.usrName;
        self.avPlayerView.titleLabel.text = model.videoTitle;
        
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

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

@end
