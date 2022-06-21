#import "TTUserInfoView.h"
#import "TTGetUserInfoData.h"
#import "Masonry.h"
#import <UIIMageView+WebCache.h>
#import "URLs.h"
#import "TTNetworkTool.h"
#define nameFont [UIFont systemFontOfSize:22]
#define accountFont [UIFont systemFontOfSize:22]
#define emailFont [UIFont systemFontOfSize:22]

@interface TTUserInfoView ()
@end

@implementation TTUserInfoView

- (instancetype) initWithData: (TTGetUserInfoData *) data{
    self = [super init];
    if (self) {
        [self initLable];
        [self initData:data];
        [self initImage:data];
        [self initButton];
    }
    return self;
}

- (void) initLable {
    //昵称标签
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"昵称:";
    _nameLabel.font = nameFont;
    // 账号标签
    _accountLabel = [[UILabel alloc] init];
    _accountLabel.text = @"账号:";
    _accountLabel.font = accountFont;
    // 邮箱标签
    _emailLabel = [[UILabel alloc] init];
    _emailLabel.text = @"邮箱:";
    _emailLabel.font = emailFont;
    
    // 容器
    _containerLabel = [[UIStackView alloc] initWithArrangedSubviews:@[_nameLabel,_accountLabel, _emailLabel]];
    _containerLabel.axis = UILayoutConstraintAxisVertical;
    // 容器中组件等距离排列
    _containerLabel.distribution = UIStackViewDistributionEqualSpacing;
    [self addSubview:_containerLabel];
}

- (void) initData: (TTGetUserInfoData *) data{
    //昵称标签
    _name = [[UILabel alloc] init];
    _name.font = nameFont;
    _name.text = data.name;
    // 账号标签
    _account = [[UILabel alloc] init];
    _account.font = accountFont;
    _account.text = data.account;
    // 邮箱标签
    _email = [[UILabel alloc] init];
    _email.font = emailFont;
    _email.text = data.mail;
    
    // 容器
    _containerData = [[UIStackView alloc] initWithArrangedSubviews:@[_name,_account, _email]];
    _containerData.axis = UILayoutConstraintAxisVertical;
    // 容器中组件等距离排列
    _containerData.distribution = UIStackViewDistributionEqualSpacing;
    [self addSubview:_containerData];
}

- (void) initImage: (TTGetUserInfoData *) data {
    _headIconView = [[UIImageView alloc] init];
    [_headIconView sd_setImageWithURL:[NSURL URLWithString:[TTNetworkTool getDownloadURLWithFileToken: data.pictureToken]] placeholderImage:[UIImage imageNamed:@"video_loading"]];
    _headIconView.contentMode = UIViewContentModeScaleAspectFit;
    _headIconView.layer.masksToBounds= YES;
    [self addSubview:_headIconView];
}

- (void) initButton{
    _updateButton = [[UIButton alloc] init];
    [_updateButton setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    _updateButton.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_updateButton];
}

- (void)layoutSubviews {
    // 图片约束
    [_headIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(30);
        make.top.mas_equalTo(self).offset(40);
        make.width.mas_equalTo(@110);
        make.height.mas_equalTo(@110);
    }];
    // 标签约束
    [_containerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@70);
        make.height.mas_equalTo(self.headIconView).offset(10);
        make.top.mas_equalTo(self.headIconView);
        make.left.mas_equalTo(self.headIconView.mas_right).offset(30);
    }];
    // 数据标签约束
    [_containerData mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@150);
        make.height.mas_equalTo(self.containerLabel);
        make.top.mas_equalTo(self.containerLabel);
        make.left.mas_equalTo(self.containerLabel.mas_right);
    }];
    
    // 按钮约束
    [_updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.top.mas_equalTo(self).offset(20);
        make.width.mas_equalTo(@30);
        make.height.mas_equalTo(@30);
    }];
    // 设置图片圆角
    [self layoutIfNeeded];
    _headIconView.layer.cornerRadius= _headIconView.bounds.size.width/2;
    // 边框的粗细
    _headIconView.layer.borderWidth = 2;
}

@end

