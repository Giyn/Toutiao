//
//  TTRegisterView.m
//  NoSceneTemp
//
//  Created by Shaw Young on 2022/6/6.
//

#import "TTRegisterView.h"
#import "TTInputField.h"
#import "Masonry.h"

@interface TTRegisterView () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@end


@implementation TTRegisterView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInputFields];
        [self setupContainer];
        [self addSubview:_containerStack];
        UIEdgeInsets paddings = UIEdgeInsetsMake(20, 20, 20, 20);
        [_containerStack setLayoutMargins:paddings];
    }
    return self;
}

- (void)initButtons {
    _registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _registerButton.backgroundColor = UIColor.systemBlueColor;
    _registerButton.tintColor = UIColor.whiteColor;
    [_registerButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_registerButton setContentEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 0)];
    [_registerButton.layer setCornerRadius:8];

    [_registerButton sizeToFit];
    [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
}

- (void)setupInputFields {
    _usernameInputField = [[TTInputField alloc]initWithLabelText:@"账号" placeholder:@"请输入账号" type:TTInputFieldTypeNormal];
    _usernameInputField.textField.textContentType = UITextContentTypeUsername;
    _usernameInputField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailInputField = [[TTInputField alloc]initWithLabelText:@"邮箱" placeholder:@"请输入邮箱" type:TTInputFieldTypeNormal];
    _emailInputField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailInputField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailInputField.textField.textContentType = UITextContentTypeEmailAddress;
    _passwordInputField = [[TTInputField alloc]initWithLabelText:@"密码" placeholder:@"请输入密码"  type:TTInputFieldTypePassword];
    [_passwordInputField.textField  setSecureTextEntry:YES];
}

- (void)setupContainer {
    _containerStack = [[UIStackView alloc]initWithArrangedSubviews:@[_usernameInputField, _emailInputField, _passwordInputField]];
    _containerStack.axis = UILayoutConstraintAxisVertical;
    _containerStack.distribution = UIStackViewDistributionEqualSpacing;
    [self initButtons];
    [_containerStack addArrangedSubview:_registerButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_containerStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self).offset(-40);
        make.center.mas_equalTo(self);
    }];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_containerStack.mas_height);
    }];
}
@end
