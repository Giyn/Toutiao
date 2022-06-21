#import <UIKit/UIKit.h>
@class TTInputField;
NS_ASSUME_NONNULL_BEGIN

@interface TTUpdateInfoView : UIView
@property (nonatomic, strong) UIStackView *containerStack;
@property (nonatomic, strong) TTInputField *usernameInputField;
@property (nonatomic, strong) TTInputField *accountInputField;
@property (nonatomic, strong) TTInputField *emailInputField;
@property (nonatomic, strong) TTInputField *passwordInputField;
@property (nonatomic, strong) UIButton *updateButton;
@end

NS_ASSUME_NONNULL_END
