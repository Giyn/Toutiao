//
//  TTInput.h
//  NoSceneTemp
//
//  Created by 肖扬 on 2022/6/6.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TTInputFieldType) {
    TTInputFieldTypeNormal,
    TTInputFieldTypePassword
};
NS_ASSUME_NONNULL_BEGIN

@interface TTInputField : UIView
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, strong) UIStackView *containerView;
@property (nonatomic, copy) NSString *placeholder;
- (instancetype)initWithLabelText:(NSString *)labelText placeholder:(NSString *)placeholder type:(TTInputFieldType)type;
@end

NS_ASSUME_NONNULL_END
