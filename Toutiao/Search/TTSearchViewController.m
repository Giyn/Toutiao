//
//  TTSearchViewController.m
//  Toutiao
//
//  Created by Admin on 2022/6/10.
//

#import "TTSearchViewController.h"
#import "TTSearchTableViewCell.h"
#import "TTWorksListController.h"
#import "UIViewController+PreviousVC.h"
#import "TTPagerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"

#import "TTSearchModel.h"
#import "TTVideoPlayController.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

@interface TTSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView * searchTableView;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) NSString *searchInput;

@property (nonatomic, strong) NSArray *modelArray;  // 模型数组
@property (nonatomic, assign) NSInteger current;
@property (nonatomic, assign) NSInteger size;

@end

@implementation TTSearchViewController

- (instancetype)initWithText:(NSString *)text{
    if (self = [super init]){
        self.searchInput = text;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpSearchView];
    [self setUpSearchTableView];
    // 加载数据
    self.current = 0;
    self.size = 10;
    [self loadData];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(slideUp)];
    header.stateLabel.hidden = YES;
    self.searchTableView.mj_header = header;
    //下拉加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [footer setTitle:@"加载更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    self.searchTableView.mj_footer = footer;
    
}

#pragma mark - 布局
// 设置searchView
- (void)setUpSearchView{
    // 初始化searchview
    self.searchView = [[UIView alloc] init];
    self.searchView.backgroundColor = [UIColor colorNamed:@"tt_red"];
    [self.view addSubview:self.searchView];
    
    // 初始化searchBar
    self.searchBar = [[UISearchBar alloc] init];
    if (@available(iOS 13.0, *)) {
        _searchBar.searchTextField.backgroundColor = UIColor.clearColor;
    } else {
        [[[self.searchBar.subviews objectAtIndex:0].subviews objectAtIndex:0] removeFromSuperview];    // 去除searchbar的背景色
    }
    self.searchBar.delegate = self;
    [self.searchView addSubview:self.searchBar];
    self.searchBar.text = self.searchInput; // 主页跳转传值
    
    // 初始化backBtn
    self.backBtn = [[UIButton alloc] init];
    [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.searchView addSubview:self.backBtn];
    
    // 初始化searchBtn
    self.searchBtn = [[UIButton alloc] init];
    [self.searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [self.searchView addSubview:self.searchBtn];
    
    // 判断刘海屏 设置searchView的尺寸
    if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20) {    // >20是刘海屏
        // 设置searchView的宽高
        [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.width);
            make.height.equalTo(88);
            make.top.equalTo(self.view.top);
        }];
    }else{  // 不是刘海屏
        [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.width);
            make.height.equalTo(64);
            make.top.equalTo(self.view.top);
        }];
    }
    
    // 设置searchBar位置
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.searchView.bottom).offset(-8);
        make.height.equalTo(32);
        make.left.equalTo(self.searchView.left).offset(50);
        make.right.equalTo(self.searchBar.right).offset(-50);
    }];
    
    // 设置backBtn位置
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchView.left).offset(8);
        make.right.equalTo(self.searchBar.left).offset(-5);
        make.centerY.equalTo(self.searchBar.centerY);
    }];
    
    // 设置searchBtn位置
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBar.right).offset(5);
        make.right.equalTo(self.searchView.right).offset(-8);
        make.centerY.equalTo(self.searchBar.centerY);
    }];
    
    // 监听btn
    [self.backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn addTarget:self action:@selector(searchClicked) forControlEvents:UIControlEventTouchUpInside];
}

// 设置searchtableview
- (void)setUpSearchTableView{
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchTableView];
    if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20) {    // 是刘海屏
        // 设置searchView的宽高
        [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.width);
            make.height.equalTo(self.view.height).offset(-88);
            make.bottom.equalTo(self.view.bottom);
        }];
    }else{
        [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.width);
            make.height.equalTo(self.view.height).offset(-64);
            make.bottom.equalTo(self.view.bottom);
        }];
    }
    
    //self.searchTableView.allowsSelection = NO;  // 禁止cell与用户互动
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    
}

// 下拉刷新
- (void)slideUp{
    self.current--;
    [self loadData];
    [self.searchTableView.mj_header endRefreshing];
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; //设置隐藏导航栏
    self.tabBarController.tabBar.hidden = YES;  // 页面出现时隐藏tabbar
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;   // 页面消失时出现tabbar
    [super viewWillDisappear:animated];
}

// 搜索键的点击事件
- (void)searchClicked{
    [self loadData];
}

// 返回键点击事件
- (void)backBtnClicked{
    // 找到上一个VC，调用其开始播放方法
    UIViewController *prevVC = [self getPreviousVC];
    if (prevVC && [prevVC isKindOfClass:TTPagerViewController.class]) {
        TTPagerViewController *pagerVC = (TTPagerViewController *)prevVC;
        [pagerVC startPlayingCurrent];
    }

    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - searchBar代理方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self loadData];
}

#pragma mark - tableView数据源方法
// 每组中的行数（后面需要根据模型来改）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // 根据模型数组count方法返回相应行数
     return self.modelArray.count;
}

// 设置单元格格式
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // 创建单元格 cell重用
    static NSString *ID = @"searchCell";
    TTSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil){
        cell = [[TTSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // 通过模型赋值
    TTSearchModel *model = self.modelArray[indexPath.row];
    [cell.imgViewIcon sd_setImageWithURL:[NSURL URLWithString:model.imgIcon]];
    cell.usrName.text = model.usrName;
    cell.videoTitle.text = model.videoTitle;
    [cell.videoImgView sd_setImageWithURL:[NSURL URLWithString:model.videoImg]];
    
    [cell settingFrame];
    
    // 返回单元格
    return cell;
}

#pragma mark - tableView代理方法
// 设置选中cell后cell的样式--cell选中后不变灰
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TTSearchTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 选中cell后跳转视频播放
    TTVideoPlayController *videoPlayVC = [[TTVideoPlayController alloc] init];
    videoPlayVC.searchText = self.searchBar.text;
    [self.navigationController pushViewController:videoPlayVC animated:YES];
    
}

#pragma mark - 网络请求
// 获取token
- (NSString *) getUserToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    return token;
}

- (void)loadData{
    [self.searchTableView.mj_footer resetNoMoreData];
    [TTSearchModel searchModelWithSuccess:^(NSArray * _Nonnull array) {
        self.modelArray = array;
        self.current ++;
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"错误" message:error.description preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    } text:self.searchBar.text current:(self.current+1) size:self.size];
}


- (void)setModelArray:(NSArray *)modelArray{
    _modelArray = modelArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchTableView reloadData];
    });
    [self.searchTableView.mj_footer endRefreshing];
    if (self.modelArray.count < self.size){
        [self.searchTableView.mj_footer endRefreshingWithNoMoreData];
    }
}

@end
