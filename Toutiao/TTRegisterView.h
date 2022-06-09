//
//  TTRegisterView.h
//  NoSceneTemp
//
//  Created by Shaw Young on 2022/6/6.
//

#import <UIKit/UIKit.h>
@class TTInputField;
NS_ASSUME_NONNULL_BEGIN

@interface TTRegisterView : UIView
@property (nonatomic, strong) UIStackView *containerStack;
@property (nonatomic, strong) TTInputField *usernameInputField;
@property (nonatomic, strong) TTInputField *emailInputField;
@property (nonatomic, strong) TTInputField *passwordInputField;
@property (nonatomic, strong) UIButton *registerButton;
@end

NS_ASSUME_NONNULL_END
