//
//  TestViewController.m
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/6.
//

#import "TTRegisterController.h"
#import "TTLoginView.h"
#import "TTInputField.h"
#import "TTLoginController.h"
#import "TTLoginResponse.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import "MJExtension.h"

NSUInteger const kLoginViewUsernameFieldTag = 111;
NSUInteger const kLoginViewEmailFieldTag = 222;
NSUInteger const kLoginViewPasswordFieldTag = 333;
NSUInteger const kLoginViewValidPasswordLength = 30;
NSString * const kLoginViewUsernameRegex = @"[A-Za-z0-9]+";
NSString * const kLoginViewEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
NSString * const kLoginViewPasswordRegex = @"(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}";

@interface TTLoginController () <UITextFieldDelegate>
@property (nonatomic, strong) TTLoginView *loginView;
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
    return [self checkStringForRegex:string regex:kLoginViewUsernameRegex];
}

- (BOOL)checkEmail:(NSString*)string {
    return [self checkStringForRegex:string regex:kLoginViewEmailRegex];
}


- (BOOL)checkPassword:(NSString *)string {
    return [self checkStringForRegex:string regex:kLoginViewPasswordRegex];
    
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
    BOOL isPasswordValid = _loginView.passwordInputField.textField.text.length < kLoginViewValidPasswordLength;
    
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
            errorMessage = @"输入的账号应仅包含26个英文字母和数字";
        } else if (!isPasswordValid) {
            errorMessage = @"输入的密码应该包含大小写和数字, 且长度在8到30个字符以内";
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

#pragma mark - 注册按钮事件
- (void)registerAction {
    if (![self isInputLegal]) {
        NSLog(@"Illegal input username: %@,  password: %@", _loginView.usernameInputField.textField.text, _loginView.passwordInputField.textField.text);
        return;
    }
    [self performLoginRequest];
}


#pragma mark - 网络请求
- (void)performLoginRequest {
    NSString *username = _loginView.usernameInputField.textField.text;
    NSString *password = _loginView.passwordInputField.textField.text;
    
    self.isPerformingRequest = YES;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    
    NSString *loginEndpoint = @"http://47.96.114.143:62318/api/user/login";
    NSMutableDictionary *mutableDict = NSMutableDictionary.new;
    mutableDict[@"account"] = username;
    mutableDict[@"password"] = password;
    
    NSURLRequest *request = [[AFJSONRequestSerializer serializer]requestWithMethod:@"POST" URLString:loginEndpoint parameters:mutableDict.copy error:nil];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        TTLoginResponse *loginResponse = [TTLoginResponse mj_objectWithKeyValues:responseObject];
        NSLog(@"%@ %@", response, responseObject);
        
        if (![loginResponse.success isEqualToString:@"1"]) {
            [strongSelf showAlertWithTitle:@"登录失败" message:loginResponse.message redirectToPrev:NO];
            return;
        } else {
            [strongSelf saveLoginResultWithToken:loginResponse.data.token expireAt:loginResponse.data.expireAt];
            [strongSelf showAlertWithTitle:@"登录成功" message:@"开始您的头条之旅" redirectToPrev:NO];
        }
    }];
    [dataTask resume];
    
}

#pragma mark - 登录结果
- (void)saveLoginResultWithToken:(NSString *)token expireAt:(NSString *)expireAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    [defaults setObject:[NSDate dateWithTimeIntervalSince1970:[expireAt doubleValue]] forKey:@"expireAt"];
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
    __block NSInteger currentVCIndex;
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
