#import "TTUserInfoController.h"
#import "TTSearchTableViewCell.h"
#import "TTWorksListController.h"
#import <MJExtension/NSObject+MJKeyValue.h>
#import "TTUserInfoView.h"
#import "Masonry.h"
#import <AFNetworking/AFURLSessionManager.h>
#import "TTGetUserInfoData.h"
#import "TTGetUserInfoResponse.h"
#import "TTGetUserInfoRequest.h"
#import "URLs.h"
#import "TTNetworkTool.h"
#import "UIIMageView+WebCache.h"
#import "TTUserInfoCell.h"
#import "TTUpdateInfoController.h"
#import "TTLoginController.h"

@interface TTUserInfoController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong)UITableView *myVideoTableView;
@property (nonatomic,strong)TTGetUserInfoData *data;
@property (nonatomic, assign) BOOL isPerformingRequest;
@end

@implementation TTUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    // 获取UserDefaults
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    // 获取token
    NSString *token = [ud valueForKey:@"token"];
    BOOL tokenExpired = NO;
    // 获取token过期时间
    NSDate *expireAt = [ud valueForKey:@"expireAt"];
    NSDate *currentTime = [NSDate date];
    // 比较token过期时间和当前时间
    if ([expireAt compare:currentTime] == NSOrderedAscending) {
        // 如果token已过期则从UserDefaults中删除相关属性
        [ud removeObjectForKey:@"token"];
        [ud removeObjectForKey:@"expireAt"];
        tokenExpired = YES;
    }
    // 登录状态有效就发起网络请求获取个人信息；登录状态无效就导航到登录界面
    if (token == nil || tokenExpired) {
        [self navToLoginWithAnimation:NO];
    } else {
        [self performLoginRequest];
    }
}

// 设置myVideoView
- (void)setUpMyVideoTableView {
    self.myVideoTableView = [[UITableView alloc] init];
    self.myVideoTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.myVideoTableView];
    // 设置searchView的宽高
    if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20) {    // 是刘海屏
        // 设置searchView的宽高
        [self.myVideoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.mas_width);
            make.height.equalTo(self.view.mas_height).offset(-88);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }else{
        [self.myVideoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.mas_width);
            make.height.equalTo(self.view.mas_height).offset(-64);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    // 设置headerView
    TTUserInfoView *userView = [[TTUserInfoView alloc] initWithData: _data];
    userView.frame = CGRectMake(0,0,self.view.frame.size.width,170);
    userView.backgroundColor = [UIColor colorNamed:@"tt_grey"];
    _myVideoTableView.tableHeaderView = userView;
    [userView.updateButton addTarget:self action:@selector(navToUpdateView) forControlEvents:UIControlEventTouchUpInside];
    
    self.myVideoTableView.dataSource = self;
    self.myVideoTableView.delegate = self;
}

- (void)navToUpdateView{
    UINavigationController *navVC = self.navigationController;
    TTUpdateInfoController *regVC = TTUpdateInfoController.new;
    [navVC pushViewController:regVC animated:YES];
}


#pragma mark - searchTableView数据源方法（组数默认1 行数 单元格格式）
// 每组中的行数（后面需要根据模型来改）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_data.worksList.records count];
}

// 设置单元格格式
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // 创建单元格 cell重用
    TTUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell"];
    if (cell == nil){
        cell = [[TTUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"info_cell"];
    }
    NSArray <TTWorkRecord *> *records =_data.worksList.records;
    TTWorkRecord *record = records[indexPath.row];
    
    [cell.videoImgView sd_setImageWithURL:[NSURL URLWithString:[TTNetworkTool getDownloadURLWithFileToken: record.pictureToken]] placeholderImage:[UIImage imageNamed:@"video_loading"]];
    cell.videoImgView.layer.masksToBounds= YES;
    cell.videoImgView.contentMode =  UIViewContentModeScaleAspectFill;
    //
    cell.videoTitle.text = record.name;
    
    [cell settingFrame];
    // 返回单元格
    return cell;
}

- (void)performLoginRequest {
    // 设置网络请求状态
    // 初始化网络请求
    TTNetworkTool *tool = [TTNetworkTool sharedManager];
    // 设置网络请求状态
    self.isPerformingRequest = YES;
    
    [tool requestWithMethod:TTHttpMethodTypeGET path:getUserInfoPath params:[[NSDictionary alloc] init] requiredToken:YES onSuccess:^(id  _Nonnull responseObject) {
        TTGetUserInfoResponse *infoResponse = [TTGetUserInfoResponse mj_objectWithKeyValues:responseObject];
        if (!infoResponse.isSuccess) {
            [self showAlertWithTitle:@"获取信息失败" message:[infoResponse mj_JSONString] redirect:NO];
            // 设置网络请求状态
            self.isPerformingRequest = NO;
            return;
        } else {
            self.data = infoResponse.data;
            [self setUpMyVideoTableView];
            self.isPerformingRequest = NO;
        }
    } onError:^(NSError * _Nonnull error) {
        [self showAlertWithTitle:@"获取信息失败" message:error.description redirect:YES];
    } onProgress:nil];
    
}

// 跳转上一页
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message redirect:(BOOL)redirectToPrev {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action;
    if (redirectToPrev) {
        action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self navToLoginWithAnimation:YES];
        }];
    } else {
        action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    }
    [alertController addAction:action];
//    [self presentViewController:alertController animated:YES completion:nil];
}


// 跳转到上一级页面
- (void)navToLoginWithAnimation:(BOOL)animated {
    UINavigationController *navVC = self.navigationController;
    TTLoginController *loginVC = TTLoginController.new;
    [navVC pushViewController:loginVC animated:animated];
}


#pragma mark - TableView的代理方法
// 设置选中cell后cell的样式--cell选中后不变灰
// 先不做视频播放
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TTUserInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    TTSearchTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}


@end
