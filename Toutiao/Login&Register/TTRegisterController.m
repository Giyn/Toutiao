//
//  TestViewController.m
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/6.
//

#import <AFNetworking/AFURLSessionManager.h>
#import <MJExtension/NSObject+MJKeyValue.h>
#import "TTRegisterController.h"
#import "TTLoginController.h"
#import "TTLoginView.h"
#import "TTInputField.h"
#import "TTRegisterView.h"
#import "Masonry.h"
#import "TTBaseResponse.h"
#import "config.h"
#import "../Network/URLs.h"
#import "../Network/TTNetworkTool.h"
#import "../Network/Request/TTRegisterRequest.h"

NSUInteger const kRegisterViewUsernameFieldTag = 111;
NSUInteger const kRegisterViewEmailFieldTag = 222;
NSUInteger const kRegisterViewPasswordFieldTag = 333;

@interface TTRegisterController () <UITextFieldDelegate>
@property (nonatomic, strong) TTRegisterView *registerView;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) NSString *registeredUsername;
@property (nonatomic, strong) NSString *registeredPassword;
@property (nonatomic, assign) BOOL isPerformingRequest;
@end

@implementation TTRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    _registerView = TTRegisterView.new;
    [self.view addSubview:_registerView];
    self.view.backgroundColor = UIColor.whiteColor;
    _registerView.usernameInputField.textField.delegate = self;
    _registerView.emailInputField.textField.delegate = self;
    _registerView.passwordInputField.textField.delegate = self;
    _registerView.usernameInputField.tag = kRegisterViewUsernameFieldTag;
    _registerView.emailInputField.tag = kRegisterViewEmailFieldTag;
    _registerView.passwordInputField.tag = kRegisterViewPasswordFieldTag;

    [_registerView.registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController setNavigationBarHidden:false];
    self.navigationItem.title = @"注册";
    _gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:_gestureRecognizer];
    _gestureRecognizer.cancelsTouchesInView = NO;
}
- (void)viewWillLayoutSubviews {

    [_registerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
    
}

#pragma mark - UITextField委托方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case kRegisterViewUsernameFieldTag:
            [textField resignFirstResponder];
            if ([_registerView.emailInputField canBecomeFirstResponder]) {
                [_registerView.emailInputField becomeFirstResponder];
            }
            break;
            
        case kRegisterViewEmailFieldTag:
            [textField resignFirstResponder];
            if ([_registerView.passwordInputField canBecomeFirstResponder]) {
                [_registerView.passwordInputField becomeFirstResponder];
            }
            break;
            
        case kRegisterViewPasswordFieldTag:
            [textField resignFirstResponder];
            [self registerAction];
            break;
            
        default:
            NSLog(@"%@", @(textField.tag));
    }
    return YES;
}

#pragma mark - 收起键盘
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 校验表单
- (BOOL)checkUsername:(NSString*)string {
    return [self checkStringForRegex:string regex:kUsernameRegex];
}

- (BOOL)checkEmail:(NSString*)string {
    return [self checkStringForRegex:string regex:kEmailRegex];
}


- (BOOL)checkPassword:(NSString *)string {
    return [self checkStringForRegex:string regex:kPasswordRegex];
    
}

- (BOOL)checkStringForRegex:(NSString *)string regex:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    return YES;
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

- (BOOL)isInputLegal {
    BOOL isUsernameEmpty = [_registerView.usernameInputField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
    BOOL isEmailEmpty = _registerView.emailInputField.textField.text.length == 0;
    BOOL isPasswordEmpty = _registerView.passwordInputField.textField.text.length == 0 ;
    BOOL isUsernameValid = [self checkUsername:_registerView.usernameInputField.textField.text];
    BOOL isEmailValid = [self checkEmail:_registerView.emailInputField.textField.text];
    BOOL isPasswordValid = _registerView.passwordInputField.textField.text.length < kValidPasswordLength && [self checkPassword:_registerView.passwordInputField.textField.text];
    
    BOOL isValid = !isUsernameEmpty && !isEmailEmpty && !isPasswordEmpty && isUsernameValid && isEmailValid && isPasswordValid;
    if (isValid) {
        return YES;
    } else {
        NSString *errorMessage;
        if (isUsernameEmpty) {
            errorMessage = @"输入的账号不能为空";
        } else if (isEmailEmpty) {
            errorMessage = @"输入的邮箱不能为空";
        } else if (isPasswordEmpty) {
            errorMessage = @"输入的密码不能为空";
        } else if (!isUsernameValid) {
            errorMessage = @"输入的账号应仅包含26个英文字母和数字";
        } else if (!isEmailValid) {
            errorMessage = @"输入的邮箱格式无效";
        } else if (!isPasswordValid) {
            errorMessage = @"输入的密码应该包含大小写和数字, 且长度在8到30个字符以内";
        }
        [self showAlertWithTitle:@"输入错误" message:errorMessage redirectToPrev:NO];
        return NO;
    }
}

#pragma mark - 注册事件
- (void)registerAction {
    if (![self isInputLegal]) {
        NSLog(@"Illegal input username: %@, email: %@, password: %@", _registerView.usernameInputField.textField.text, _registerView.emailInputField.textField.text, _registerView.passwordInputField.textField.text);
        return;
    }
    if (_isPerformingRequest) {
        [self showAlertWithTitle:@"网络繁忙" message:@"正在请求中，请稍后再试" redirectToPrev:NO];
    }
    [self performRegisterRequest];
}

#pragma mark - 网络请求
- (void)performRegisterRequest {
    NSString *username = _registerView.usernameInputField.textField.text;
    NSString *email = _registerView.emailInputField.textField.text;
    
    TTRegisterRequest *registerRequest = TTRegisterRequest.new;
    NSString *password = _registerView.passwordInputField.textField.text;
    registerRequest.account = username;
    registerRequest.name = username;
    registerRequest.password = password;
    registerRequest.mail = email;
    
    NSDictionary *params = [registerRequest mj_keyValues].copy;
    
    self.isPerformingRequest = YES;
    TTNetworkTool *manager = [TTNetworkTool sharedManager];
    [manager requestWithMethod:TTHttpMethodTypePOST path:registerPath params:params requiredToken:NO onSuccess:^(id  _Nonnull responseObject) {
            TTBaseResponse *baseResponse = [TTBaseResponse mj_objectWithKeyValues:responseObject];
            if (!baseResponse.isSuccess) {
                self.isPerformingRequest = NO;
                [self showAlertWithTitle:@"注册失败" message:baseResponse.message redirectToPrev:NO];
                return;
            } else {
                self.isPerformingRequest = NO;
                [self showAlertWithTitle:@"注册成功" message:@"即将前往登录界面" redirectToPrev:YES];
                self.registeredUsername = username;
                self.registeredPassword = password;
            }
        } onError:^(NSError * _Nonnull error) {
            self.isPerformingRequest = NO;
            [self showAlertWithTitle:@"注册失败" message:@"即将前往登录界面" redirectToPrev:YES];
        } onProgress:nil];
}

#pragma mark - 跳转到上一级页面
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
    UIViewController *prevVC = navVC.viewControllers[currentVCIndex-1];
    if ([prevVC isKindOfClass:TTLoginController.class]) {
        TTLoginController *loginVC = (TTLoginController *)prevVC;
        TTLoginView *loginView = loginVC.loginView;
        loginView.usernameInputField.textField.text = _registeredUsername;
        loginView.passwordInputField.textField.text = _registeredPassword;
        _registeredUsername = @"";
        _registeredPassword = @"";
    }
    [navVC popToViewController:navVC.viewControllers[currentVCIndex-1] animated:YES];
}

@end
