//
//  TestViewController.m
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/6.
//

#import "TTRegisterController.h"
#import "TTInputField.h"
#import "TTRegisterView.h"

#import "Masonry.h"

NSUInteger const kRegisterViewUsernameFieldTag = 111;
NSUInteger const kRegisterViewEmailFieldTag = 222;
NSUInteger const kRegisterViewPasswordFieldTag = 333;
NSUInteger const kRegisterViewValidPasswordLength = 30;
NSString * const kRegisterViewUsernameRegex = @"[A-Za-z0-9]+";
NSString * const kRegisterViewEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
NSString * const kRegisterViewPasswordRegex = @"(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}";

@interface TTRegisterController () <UITextFieldDelegate>
@property (nonatomic, strong) TTRegisterView *registerView;
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

    [_registerView.registerButton addTarget:self action:@selector(isInputLegal) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController setNavigationBarHidden:false];
    self.navigationItem.title = @"注册";
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
            NSLog(@"登录");
            break;
            
        default:
            NSLog(@"%@", @(textField.tag));
    }
    return YES;
}

#pragma mark - 校验表单
- (BOOL)checkUsername:(NSString*)string {
    return [self checkStringForRegex:string regex:kRegisterViewUsernameRegex];
}

- (BOOL)checkEmail:(NSString*)string {
    return [self checkStringForRegex:string regex:kRegisterViewEmailRegex];
}


- (BOOL)checkPassword:(NSString *)string {
    return [self checkStringForRegex:string regex:kRegisterViewPasswordRegex];
    
}

- (BOOL)checkStringForRegex:(NSString *)string regex:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    return YES;
}


- (BOOL)isInputLegal {
    BOOL isUsernameEmpty = [_registerView.usernameInputField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
    BOOL isEmailEmpty = _registerView.emailInputField.textField.text.length == 0;
    BOOL isPasswordEmpty = _registerView.passwordInputField.textField.text.length == 0 ;
    BOOL isUsernameValid = [self checkUsername:_registerView.usernameInputField.textField.text];
    BOOL isEmailValid = [self checkEmail:_registerView.emailInputField.textField.text];
    BOOL isPasswordValid = _registerView.passwordInputField.textField.text.length < kRegisterViewValidPasswordLength && [self checkPassword:_registerView.passwordInputField.textField.text];
    
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"输入错误" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
}

- (void)resignAllFieldRespondersWithNextResponder:(UITextField *)nextResponder {
    if (_registerView.usernameInputField.isFirstResponder) {
        NSLog(@"username, %@", @(_registerView.usernameInputField.resignFirstResponder));
        [_registerView.usernameInputField resignFirstResponder];
    }
    if (_registerView.emailInputField.isFirstResponder) {
        NSLog(@"email, %@", @(_registerView.usernameInputField.resignFirstResponder));
        [_registerView.emailInputField resignFirstResponder];
    }
    if (_registerView.passwordInputField.isFirstResponder) {
        NSLog(@"password, %@", @(_registerView.usernameInputField.resignFirstResponder));
        [_registerView.passwordInputField resignFirstResponder];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
