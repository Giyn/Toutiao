#import <AFNetworking/AFURLSessionManager.h>
#import <MJExtension/NSObject+MJKeyValue.h>
#import "TTRegisterController.h"
#import "TTLoginController.h"
#import "TTUserInfoController.h"
#import "TTInputField.h"
#import "TTUpdateInfoView.h"
#import "Masonry.h"
#import "TTBaseResponse.h"
#import "config.h"
#import "../Network/URLs.h"
#import "../Network/TTNetworkTool.h"
#import "../Network/Request/TTUpdateUserInfoRequest.h"

#import "TTUpdateInfoController.h"

NSUInteger const viewUsernameFieldTag = 1;
NSUInteger const viewAccountFieldTag = 2;
NSUInteger const viewEmailFieldTag = 3;
NSUInteger const viewPasswordTag = 4;


@interface TTUpdateInfoController () <UITextFieldDelegate>
@property (nonatomic, strong) TTUpdateInfoView *updateInfoView;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic, assign) BOOL isPerformingRequest;
@end

@implementation TTUpdateInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    _updateInfoView = TTUpdateInfoView.new;
    [self.view addSubview: _updateInfoView];
    self.view.backgroundColor = UIColor.whiteColor;
    _updateInfoView.usernameInputField.textField.delegate = self;
    _updateInfoView.accountInputField.textField.delegate = self;
    _updateInfoView.emailInputField.textField.delegate = self;
    _updateInfoView.passwordInputField.textField.delegate = self;
    
    _updateInfoView.usernameInputField.tag = viewUsernameFieldTag;
    _updateInfoView.accountInputField.tag = viewAccountFieldTag;
    _updateInfoView.emailInputField.tag = viewEmailFieldTag;
    _updateInfoView.passwordInputField.tag = viewPasswordTag;
    
    [_updateInfoView.updateButton addTarget:self action:@selector(updateAction) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController setNavigationBarHidden:false];
    self.navigationItem.title = @"更新个人信息";
    _gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:_gestureRecognizer];
    _gestureRecognizer.cancelsTouchesInView = NO;
}



- (void)viewWillLayoutSubviews {
    [_updateInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(500);
    }];
    
}

#pragma mark - UITextField委托方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case viewUsernameFieldTag:
            [textField resignFirstResponder];
            if ([_updateInfoView.usernameInputField canBecomeFirstResponder]) {
                [_updateInfoView.usernameInputField becomeFirstResponder];
            }
            break;
            
        case viewAccountFieldTag:
            [textField resignFirstResponder];
            if ([_updateInfoView.accountInputField canBecomeFirstResponder]) {
                [_updateInfoView.accountInputField becomeFirstResponder];
            }
            break;
        case viewEmailFieldTag:
            [textField resignFirstResponder];
            if ([_updateInfoView.emailInputField canBecomeFirstResponder]) {
                [_updateInfoView.emailInputField becomeFirstResponder];
            }
            break;
        case viewPasswordTag:
            [textField resignFirstResponder];
            [self updateAction];
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
    BOOL isUsernameEmpty = [_updateInfoView.usernameInputField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
    BOOL isEmailEmpty = _updateInfoView.emailInputField.textField.text.length == 0;
    BOOL isPasswordEmpty = _updateInfoView.passwordInputField.textField.text.length == 0 ;
    BOOL isUsernameValid = [self checkUsername:_updateInfoView.usernameInputField.textField.text];
    BOOL isEmailValid = [self checkEmail:_updateInfoView.emailInputField.textField.text];
    BOOL isPasswordValid = _updateInfoView.passwordInputField.textField.text.length < kValidPasswordLength && [self checkPassword:_updateInfoView.passwordInputField.textField.text];
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

#pragma mark - 更新事件
- (void)updateAction {
    if (![self isInputLegal]) {
        NSLog(@"Illegal input username: %@, account: %@, email: %@, password: %@", _updateInfoView.usernameInputField.textField.text, _updateInfoView.accountInputField, _updateInfoView.emailInputField.textField.text, _updateInfoView.passwordInputField.textField.text);
        return;
    }
    if (_isPerformingRequest) {
        [self showAlertWithTitle:@"网络繁忙" message:@"正在请求中，请稍后再试" redirectToPrev:NO];
    }
    [self performRegisterRequest];
}

#pragma mark - 网络请求
- (void)performRegisterRequest {
    NSString *username = _updateInfoView.usernameInputField.textField.text;
    NSString *email = _updateInfoView.emailInputField.textField.text;
    NSString *account = _updateInfoView.accountInputField.textField.text;
    NSString *password = _updateInfoView.passwordInputField.textField.text;
    
    TTRegisterRequest *updateRequest = TTRegisterRequest.new;
    updateRequest.account = account;
    updateRequest.name = username;
    updateRequest.password = password;
    updateRequest.mail = email;
    
    NSDictionary *params = [updateRequest mj_keyValues].copy;
    
    self.isPerformingRequest = YES;
    TTNetworkTool *manager = [TTNetworkTool sharedManager];
    [manager requestWithMethod:TTHttpMethodTypePOST path:updateUserInfoPath params:params requiredToken:YES onSuccess:^(id  _Nonnull responseObject) {
        TTBaseResponse *baseResponse = [TTBaseResponse mj_objectWithKeyValues:responseObject];
        if (!baseResponse.isSuccess) {
            self.isPerformingRequest = NO;
            [self showAlertWithTitle:@"更新失败" message:baseResponse.message redirectToPrev:NO];
            return;
        } else {
            self.isPerformingRequest = NO;
            [self showAlertWithTitle:@"更新成功" message:@"更新成功" redirectToPrev:YES];
        }
    } onError:^(NSError * _Nonnull error) {
        self.isPerformingRequest = NO;
        [self showAlertWithTitle:@"更新失败" message:@"即将返回个人主页" redirectToPrev:YES];
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
    [navVC popToViewController:navVC.viewControllers[currentVCIndex-1] animated:YES];
}


@end
