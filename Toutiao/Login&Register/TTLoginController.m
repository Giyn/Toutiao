//
//  TestViewController.m
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/6.
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import <MJExtension/NSObject+MJKeyValue.h>
#import "TTRegisterController.h"
#import "TTLoginView.h"
#import "TTInputField.h"
#import "TTLoginController.h"
#import "TTLoginResponse.h"
#import "config.h"
#import "Masonry.h"
#import "URLs.h"
#import "TTNetworkTool.h"
#import "TTLoginRequest.h"
#import "TTUserInfoController.h"

NSUInteger const kLoginViewUsernameFieldTag = 111;
NSUInteger const kLoginViewPasswordFieldTag = 333;

@interface TTLoginController () <UITextFieldDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic, assign) BOOL isPerformingRequest;
@end

@implementation TTLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    _loginView = TTLoginView.new;
    [self.view addSubview:_loginView];
    self.view.backgroundColor = UIColor.whiteColor;
    _loginView.usernameInputField.textField.delegate = self;
    _loginView.passwordInputField.textField.delegate = self;
    _loginView.usernameInputField.tag = kLoginViewUsernameFieldTag;
    _loginView.passwordInputField.tag = kLoginViewPasswordFieldTag;
    [_loginView.loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.registerButton addTarget:self action:@selector(navToRegisterView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.title = @"登录";
    [self.navigationController setNavigationBarHidden:NO];
    _gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:_gestureRecognizer];
    _gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)viewWillLayoutSubviews {
    [_loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(270);
    }];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case kLoginViewUsernameFieldTag:
            [textField resignFirstResponder];
            if ([_loginView.passwordInputField canBecomeFirstResponder]) {
                [_loginView.passwordInputField becomeFirstResponder];
            }
            break;
            
        case kLoginViewPasswordFieldTag:
            [textField resignFirstResponder];
            [self loginAction];
            break;
            
        default:
            NSLog(@"Unknown Tag: %@", @(textField.tag));
    }
    return YES;
}

#pragma mark - 校验表单
- (BOOL)checkUsername:(NSString*)string {
    return [self checkStringForRegex:string regex:kUsernameRegex];
}

- (BOOL)checkStringForRegex:(NSString *)string regex:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    return YES;
}

- (BOOL)isInputLegal {
    BOOL isUsernameEmpty = [_loginView.usernameInputField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
    BOOL isPasswordEmpty = _loginView.passwordInputField.textField.text.length == 0 ;
    BOOL isUsernameValid = [self checkUsername:_loginView.usernameInputField.textField.text];
    BOOL isPasswordValid = _loginView.passwordInputField.textField.text.length < kValidPasswordLength;
    
    BOOL isValid = !isUsernameEmpty && !isPasswordEmpty && isUsernameValid && isPasswordValid;
    if (isValid) {
        return YES;
    } else {
        NSString *errorMessage;
        if (isUsernameEmpty) {
            errorMessage = @"输入的账号不能为空";
        } else if (isPasswordEmpty) {
            errorMessage = @"输入的密码不能为空";
        } else if (!isUsernameValid) {
            // 因为注册的时候做了大小写数字以及最低长度为8位校验，这里只限制最大长度
            errorMessage = @"输入的账号长度应在30个字符以内";
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"输入错误" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
}

#pragma mark - 登录事件
- (void)loginAction {
    if (![self isInputLegal]) {
        NSLog(@"Illegal input username: %@, password: %@", _loginView.usernameInputField.textField.text,  _loginView.passwordInputField.textField.text);
        return;
    }
    if (_isPerformingRequest) {
        [self showAlertWithTitle:@"网络繁忙" message:@"正在请求中，请稍后再试" redirectToPrev:NO];
    }
    [self performLoginRequest];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message redirectToPrev:(BOOL)redirectToPrev {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action;
    if (redirectToPrev) {
        action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 点击Action返回到登录页的上一个页面
            [self navToPrev];
        }];
    } else {
        action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    }
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 收起键盘
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 网络请求
- (void)performLoginRequest {
    // 从输入框获取账号密码
    NSString *username = _loginView.usernameInputField.textField.text;
    NSString *password = _loginView.passwordInputField.textField.text;
    // 设置网络请求状态
    self.isPerformingRequest = YES;
    // 表单
    TTLoginRequest *loginRequest = TTLoginRequest.new;
    loginRequest.account = username;
    loginRequest.password = password;
    NSDictionary *params = [loginRequest mj_keyValues].copy;
    // 初始化网络请求
    TTNetworkTool *tool = [TTNetworkTool sharedManager];
    [tool requestWithMethod:TTHttpMethodTypePOST path:loginPath params:params requiredToken:NO onSuccess:^(id  _Nonnull responseObject) {
        self.isPerformingRequest = NO;
        TTLoginResponse *loginResponse = [TTLoginResponse mj_objectWithKeyValues:responseObject];
        if (!loginResponse.isSuccess) {
            [self showAlertWithTitle:@"登录失败" message:[loginResponse mj_JSONString] redirectToPrev:NO];
            return;
        } else {
            [self saveLoginResultWithToken:loginResponse.data.token expireAt:loginResponse.data.expireAt];
            [self showAlertWithTitle:@"登录成功" message:@"开始您的头条之旅" redirectToPrev:NO];
            UINavigationController *navVC = self.navigationController;
            TTUserInfoController *regVC = TTUserInfoController.new;
            [navVC pushViewController:regVC animated:YES];
        }
    } onError:^(NSError * _Nonnull error) {
        self.isPerformingRequest = NO;
        [self showAlertWithTitle:@"登录失败" message:error.description redirectToPrev:NO];
    } onProgress:nil];
}

#pragma mark - 登录结果
- (void)saveLoginResultWithToken:(NSString *)token expireAt:(NSInteger)expireAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    // 转换成10位时间戳
    [defaults setObject:[NSDate dateWithTimeIntervalSince1970:expireAt/1000] forKey:@"expireAt"];
    NSLog(@"%@", [defaults objectForKey:@"expireAt"]);
    NSLog(@"%@", [defaults objectForKey:@"token"]);
}

#pragma mark - Navigation
- (void)navToRegisterView {
    UINavigationController *navVC = self.navigationController;
    TTRegisterController *regVC = TTRegisterController.new;
    [navVC pushViewController:regVC animated:YES];
}

// 跳转到上一级页面
- (void)navToPrev {
    UINavigationController *navVC = self.navigationController;
    __block NSUInteger currentVCIndex;
    [navVC.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqual:self]) {
                currentVCIndex = idx;
                *stop = YES;
                return;
            }
    }];
    if (currentVCIndex == 0) {
        return;
    }
    [navVC popToViewController:navVC.viewControllers[currentVCIndex-1] animated:YES];
}

@end
