
#import <UIKit/UIKit.h>
#import "TTGetUserInfoData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTUserInfoView : UIView
@property (nonatomic, strong) UIStackView *containerLabel;
@property (nonatomic, strong) UIStackView *containerData;
@property (nonatomic, strong) UILabel *accountLabel;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *account;
@property (nonatomic, strong) UILabel *email;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIImageView *headIconView;
@property (nonatomic, strong) UIButton *updateButton;
- (instancetype) initWithData: (TTGetUserInfoData *) data;

@end
NS_ASSUME_NONNULL_END
