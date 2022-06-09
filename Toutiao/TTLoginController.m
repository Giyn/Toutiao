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

#import "Masonry.h"

NSUInteger const kLoginViewUsernameFieldTag = 111;
NSUInteger const kLoginViewEmailFieldTag = 222;
NSUInteger const kLoginViewPasswordFieldTag = 333;
NSUInteger const kLoginViewValidPasswordLength = 30;
NSString * const kLoginViewUsernameRegex = @"[A-Za-z0-9]+";
NSString * const kLoginViewEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
NSString * const kLoginViewPasswordRegex = @"(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}";

@interface TTLoginController () <UITextFieldDelegate>
@property (nonatomic, strong) TTLoginView *loginView;
//@property (nonatomic, strong) TTRegisterView *registerView;
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
    [_loginView.loginButton addTarget:self action:@selector(isInputLegal) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.registerButton addTarget:self action:@selector(navToRegisterView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.title = @"登录";
    [self.navigationController setNavigationBarHidden:NO];
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
            NSLog(@"登录");
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
    BOOL isPasswordValid = _loginView.passwordInputField.textField.text.length < kLoginViewValidPasswordLength && [self checkPassword:_loginView.passwordInputField.textField.text];
    
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)navToRegisterView {
    UINavigationController *navVC = self.navigationController;
    TTRegisterController *regVC = TTRegisterController.new;
    [navVC pushViewController:regVC animated:YES];
}


@end
