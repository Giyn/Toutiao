//
//  TTSearchViewController.m
//  Toutiao
//
//  Created by Admin on 2022/6/10.
//

#import "TTSearchViewController.h"
#import "TTSearchTableViewCell.h"
#import "TTVideoStreamController.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

@interface TTSearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong)UITableView * searchTableView;
@property (nonatomic,strong)UIView *searchView;
@property (nonatomic,strong)UISearchBar *searchBar;
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UIButton *searchBtn;
@property (nonatomic,strong)NSString *searchInput;

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
    self.tabBarController.tabBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpSearchView];
    [self setUpSearchTableView];
}

// 设置searchView
- (void)setUpSearchView{
    // 初始化searchview
    self.searchView = [[UIView alloc] init];
    self.searchView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.searchView];
    
    // 初始化searchBar
    self.searchBar = [[UISearchBar alloc] init];
    [[[self.searchBar.subviews objectAtIndex:0].subviews objectAtIndex:0] removeFromSuperview];    // 去除searchbar的背景色
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

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; //设置隐藏
    [super viewWillAppear:animated];
}

// 搜索键的点击事件
- (void)searchClicked{
    NSLog(@"搜索");
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

// 返回键点击事件
- (void)backBtnClicked{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - searchTableView数据源方法（组数默认1 行数 单元格格式）
// 每组中的行数（后面需要根据模型来改）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

// 设置单元格格式
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // 获取模型数据（根据indexpath从模型数组中取出对应的模型）
    // 以下数据是示例
    NSURL *url = [NSURL URLWithString:@"https://v-cdn.zjol.com.cn/276982.mp4"];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    //AVPlayer *player = [AVPlayer playerWithPlayerItem:nil];
    
    // 创建单元格 cell重用
    static NSString *ID = @"search_cell";
    TTSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil){
        cell = [[TTSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // 设置单元格数据 单元格中添加模型属性 赋值时把模型赋值给单元中的属性就行(数据和frame)
    cell.imgViewIcon.image = [UIImage imageNamed:@"icon1"];
    cell.usrName.text = @"用户名";
    cell.videoTitle.text = @"标题标题标题标题标题";
    cell.playerVC.player = player;
    
    [cell settingFrame];
    
    // 返回单元格
    return cell;
}

#pragma mark - TableView的代理方法
// 设置选中cell后cell的样式--cell选中后不变灰
// 选中cell后跳转视频播放?
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TTSearchTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}


@end
