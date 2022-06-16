//
//  TTSearchViewController.m
//  Toutiao
//
//  Created by Admin on 2022/6/10.
//

#import "TTSearchViewController.h"
#import "TTSearchTableViewCell.h"
#import "TTVideoStreamController.h"
#import "AFHTTPSessionManager.h"
//#import "TTSearchModel.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

@interface TTSearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * searchTableView;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) NSString *searchInput;

@property (nonatomic, strong) NSArray *modelArray;  // 模型数组

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
    //[self loadData];
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
    NSLog(@"搜索");
}

// 返回键点击事件
- (void)backBtnClicked{
    // 发送通知 点击返回时视频继续播放
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"returnToHomepage" object:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - searchTableView数据源方法（组数默认1 行数 单元格格式）
// 每组中的行数（后面需要根据模型来改）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
    
    // 根据模型数组count方法返回相应行数
    // return self.modelArray.count;
}

// 设置单元格格式
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // 创建单元格 cell重用
    static NSString *ID = @"search_cell";
    TTSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil){
        cell = [[TTSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // 设置单元格数据 单元格中添加模型属性 赋值时把模型赋值给单元中的属性就行(数据和frame)
    // 以下数据是示例
//    NSURL *url = [NSURL URLWithString:@"https://v-cdn.zjol.com.cn/276982.mp4"];
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
//    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    //AVPlayer *player = [AVPlayer playerWithPlayerItem:nil];
    cell.imgViewIcon.image = [UIImage imageNamed:@"icon1"];
    cell.usrName.text = @"用户名";
    cell.videoTitle.text = @"标题标题标题标题标题";
    //cell.playerVC.player = player;
    
    // 通过模型赋值
    // cell.searchModel = self.modelArray[indexPath.row];
    
    [cell settingFrame];
    
    // 返回单元格
    return cell;
}

#pragma mark - TableView的代理方法
// 设置选中cell后cell的样式--cell选中后不变灰
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TTSearchTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 选中cell后跳转视频播放
    TTVideoStreamController *videoVc = [[TTVideoStreamController alloc] init];
    videoVc.isFromSearch = YES;
    [self.navigationController pushViewController:videoVc animated:YES];
    
}

#pragma mark - 处理模型
// 获取token
- (NSString *) getUserToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    return token;
}

// 下面是加入model后两个方法
// 加载数据 通过model内部请求函数 成功则回调模型数组
- (void)loadData{
//    [TTSearchModel searchModelWithSuccess:^(NSArray * _Nonnull array) {
//            self.modelArray = array;    // 成功获取数组后赋值给modelArray属性（调用set方法刷新数据）
//        } error:^{
//            NSLog(@"获取数据出错");
//        }];
    
//    NSString *urlStr = @"****************";
//     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//       [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//           NSLog(@"----requestData:%@",responseObject);
//           NSArray *dataInfo = responseObject[@"data"];
//           for (NSDictionary *dic in dataInfo) {
//               PlayerModel *model = [[PlayerModel alloc]initWithDictory:dic];
//               [_data addObject:model];
//           }
//           [self.tableView reloadData];
//       } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//           //
//           NSLog(@"---requesterror:%@",error);
//       }];
    NSString *searchText = self.searchBar.text;
    NSString *token = @"Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIzZjk1YzNmNy1hMzc1LTRhZDUtYWM5Ni04Y2M5NzkxYmUzMTg1NDVmOWMyOC1lYzkxLTQ0YWYtYmViNS1kODA2YzY3ZDNkOTYiLCJpc3MiOiJUb3B2aWV3IiwiZXhwIjoxNjU1MzQ4NjQ5fQ.l8bhXXwhBso_jjihVD1Khq4WMt4ur84HcCU0ZE_F9aY9xAzu0yy9v8z8yQtF556HGR2delnDdVfVVKG5QPuACTBjHdcRmHgtz1_imxYfXe41DpxD2YzIOQpWoAEQ3BJIJBdI7QV9RntmhiSzouCwjQZ4T4UmOhiAbliBzUZhXbmXGgVLX3Uhvrx5jHT5RRJtwC4TLGnxUjSb6ucMrBvANSfg13NSCbbFJ9xXBb4obY39qDyQJdgky0ITQbV3WZhiZaDCsYcdfHHiSyOaZgriWhfObhI2SBk3dBQwBL_fqEDjjHGXDUMmagt0e6My4AsVT8OvgqeLcIfPhjYlbbOcI9UvQFzOue6z5fybVvgSS-zYDgUuqLxVuhwcEjHVFwJLjbvfbjwZItQDyt8qvIcEq8BKuAiZqG12OX0dROHCyJv5E3WhgiKElN9is6ASkDokPeqdzrrvJAh9w5hO3nPNviOrUkmBMtOiE_E4oGer-igxuZDW7WUCZeMWf8D_TmwHjuJdNA7-CCuGqd9X9m_mWCMIyWBtCZ-FDuCtjUJfBYVEbjNX97Hj53LlQgY04qhWTjb7IVLFIevgNwiE5uAAx8BlPFwN5o0oB9sNfxykE1LMfqJr2WrzPushRVToR-5cW_Gmi-rpp_LodjWWTWC-b8kWedjJgzJTwlBRgJn4Qnc";
    
    // 获取token
//    NSString *token = [self getUserToken];

    NSString *baseUrl = @"http:/47.96.114.143:62318/api/works/searchWorks?searchString=";
    NSString *url = [baseUrl stringByAppendingString:searchText];
    NSLog(@"%@", url);
    
    [[AFHTTPSessionManager manager] GET:url parameters:nil headers:@{@"Authorization":token} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"%@", responseObject);
            // 获取响应体（作品id，标题，图片token，视频token，用户名，用户头像）
            NSArray *data = responseObject[@"data"][@"records"];
            NSLog(@"%@", data);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error);
        }];

}

// 重写modelArray的set方法
- (void)setModelArray:(NSArray *)modelArray{
    self.modelArray = modelArray;
    
    // 加载完数据后 刷新tableview数据
    [self.searchTableView reloadData];
}

@end
