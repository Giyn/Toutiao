//
//  TTInput.m
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/6.
//

#import "TTInputField.h"
#import "Masonry.h"
#import "UIView+Border.h"

@interface TTInputField ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *bottomMargin;
@end
@implementation TTInputField

- (instancetype)initWithLabelText:(NSString *)labelText placeholder:(NSString *)placeholder type:(TTInputFieldType)type {
    switch (type) {
        case TTInputFieldTypeNormal:
            self = [self initTTInputFieldTypeNormal];
            break;
            
        case TTInputFieldTypePassword:
            self = [self initTTInputFieldTypePassword];
            break;
    }
    _label.text = labelText;
    _textField.placeholder = placeholder;
    return self;
}

- (instancetype)initTTInputFieldTypeNormal {
    self = [super init];
    if (self) {
        _textField = UITextField.new;
        _label = UILabel.new;
        _containerView = [[UIStackView alloc]initWithArrangedSubviews:@[_label, _textField]];
        [self setupTextFieldPaddingLeft];
        [self setupTextFieldClearButton];
        [self setupLabel];
        [self setupContainer];
    }
    return self;
}

- (instancetype)initTTInputFieldTypePassword {
    self = [super init];
    if (self) {
        _textField = UITextField.new;
        _label = UILabel.new;
        _containerView = [[UIStackView alloc]initWithArrangedSubviews:@[_label, _textField]];
        [self setupTextFieldPaddingLeft];
        [self setupTextFieldVisibilityButton];
        [self setupLabel];
        [self setupContainer];
    }
    return self;
}



- (void)setupTextFieldPaddingLeft {
    _textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 25)];
    [_textField.leftView addLeftBorderWithColor:UIColor.blackColor andWidth:0.5];
    _textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setupTextFieldVisibilityButton {
    UIImage *image = [UIImage systemImageNamed:@"eye"];
    _textField.rightView = [UIButton systemButtonWithImage:image target:self action: @selector(toggleVisibility)];
    [_textField.rightView sizeToFit];
    _textField.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setupTextFieldClearButton {
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 25)];
    _textField.rightViewMode = UITextFieldViewModeUnlessEditing;
}

- (void)setupLabel {
    _label.textAlignment = NSTextAlignmentCenter;
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(50);
    }];
}

- (void)setupContainer {
    _containerView.axis = UILayoutConstraintAxisHorizontal;
    _containerView.alignment = UIStackViewAlignmentCenter;
    _containerView.layer.masksToBounds = YES;
    [_containerView.layer setCornerRadius:10];
    [_containerView.layer setBorderWidth:0.5];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
    }];
    [self addSubview:_containerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self);
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
    }];
}

#pragma mark - Override Responder Methods

- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textField resignFirstResponder];
}

- (BOOL)canBecomeFocused {
    return [_textField canBecomeFocused];
}

- (BOOL)canBecomeFirstResponder {
    return [_textField canBecomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return [_textField canResignFirstResponder];
}

- (void)setTag:(NSInteger)tag {
    return [_textField setTag:tag];
}

#pragma mark - Toggle Password Visibility

- (void)toggleVisibility {
    [self.textField setSecureTextEntry:!self.textField.secureTextEntry];
}

@end
