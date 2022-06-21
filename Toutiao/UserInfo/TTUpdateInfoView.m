#import "TTUpdateInfoView.h"
#import "TTInputField.h"
#import "Masonry.h"

@interface TTUpdateInfoView () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation TTUpdateInfoView

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
    _updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _updateButton.backgroundColor = [UIColor colorNamed:@"tt_red"];
    _updateButton.tintColor = UIColor.whiteColor;
    [_updateButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_updateButton setContentEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 0)];
    [_updateButton.layer setCornerRadius:8];
    
    [_updateButton sizeToFit];
    [_updateButton setTitle:@"更新" forState:UIControlStateNormal];
}

- (void)setupInputFields {
    
    _usernameInputField = [[TTInputField alloc]initWithLabelText:@"昵称" placeholder:@"请输入昵称" type:TTInputFieldTypeNormal];
    _usernameInputField.textField.textContentType = UITextContentTypeUsername;
    _usernameInputField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _accountInputField = [[TTInputField alloc]initWithLabelText:@"账号" placeholder:@"请输入账号" type:TTInputFieldTypeNormal];
    _accountInputField.textField.textContentType = UITextContentTypeUsername;
    _accountInputField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _emailInputField = [[TTInputField alloc]initWithLabelText:@"邮箱" placeholder:@"请输入邮箱" type:TTInputFieldTypeNormal];
    _emailInputField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailInputField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailInputField.textField.textContentType = UITextContentTypeEmailAddress;
    
    _passwordInputField = [[TTInputField alloc]initWithLabelText:@"密码" placeholder:@"请输入密码"  type:TTInputFieldTypePassword];
    [_passwordInputField.textField  setSecureTextEntry:YES];
    
}

- (void)setupContainer {
    _containerStack = [[UIStackView alloc]initWithArrangedSubviews:@[_usernameInputField, _accountInputField, _emailInputField, _passwordInputField]];
    _containerStack.axis = UILayoutConstraintAxisVertical;
    _containerStack.distribution = UIStackViewDistributionEqualSpacing;
    [self initButtons];
    [_containerStack addArrangedSubview:_updateButton];
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
