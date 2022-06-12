//
//  TTSearchTableViewCell.m
//  Toutiao
//
//  Created by Admin on 2022/6/10.
//

#import "TTSearchTableViewCell.h"
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

#define nameFont [UIFont systemFontOfSize:16]
#define videoTitleFont [UIFont systemFontOfSize:18]
#define heightToWidth 0.5625

@interface TTSearchTableViewCell ()
@end

@implementation TTSearchTableViewCell

// 重写cell初始化方法
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        // 创建子控件
        // 1 头像
        UIImageView *imgViewIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:imgViewIcon];
        self.imgViewIcon = imgViewIcon;
        
        // 2 用户名
        UILabel *usrName = [[UILabel alloc] init];
        usrName.font = nameFont;
        usrName.numberOfLines = 1;  // 显示1行后自动换行
        [self.contentView addSubview:usrName];
        self.usrName = usrName;
        
        // 3 视频标题
        UILabel *videoTitle = [[UILabel alloc] init];
        videoTitle.font = videoTitleFont;
        videoTitle.numberOfLines = 2;   // 显示2行后自动换行
        [self.contentView addSubview:videoTitle];
        self.videoTitle = videoTitle;
        
        // 4 视频
        UIView *videoContainer = [[UIView alloc] init];
        videoContainer.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:videoContainer];
        self.videoContainer = videoContainer;
        
        // 6 playerVC
        self.playerVC = [[AVPlayerViewController alloc] init];
        [self.videoContainer addSubview:self.playerVC.view];

    }
    return self;
}

// 设置cell中控件的位置
- (void)settingFrame{
    // 统一间距
    CGFloat margin = 10;
    
    // 头像
    [self.imgViewIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(35);
        make.height.equalTo(35);
        make.left.equalTo(self.contentView.left).offset(margin);
        make.top.equalTo(self.contentView.top).offset(margin);
    }];
    
    // 用户名
    // 根据label中文字内容动态计算label的宽和高
    CGSize usrNameSize = [self sizeWithText:self.usrName.text andMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) andFont:nameFont];
    
    [self.usrName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgViewIcon.right).offset(margin);
        make.centerY.equalTo(self.imgViewIcon.centerY);
        make.width.equalTo(usrNameSize.width);
        make.height.equalTo(usrNameSize.height);
    }];
    
    // 更新view中的frame 因为视频标题用了sizewithattrbutes方法，masonry布局的尺寸有误差
    [self.contentView layoutIfNeeded];
    
    // 视频标题
    CGFloat videoTitleX = margin;
    CGFloat videoTitleY = CGRectGetMaxY(self.imgViewIcon.frame) + margin;
    CGSize titleSize = [self sizeWithText:self.videoTitle.text andMaxSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*margin, MAXFLOAT) andFont:videoTitleFont]; //动态计算宽高
    CGFloat videoTitleW = titleSize.width;
    CGFloat videoTitleH = titleSize.height;
    self.videoTitle.frame = CGRectMake(videoTitleX, videoTitleY, videoTitleW, videoTitleH);
    
    // 视频
    [self.videoContainer makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgViewIcon.left);
        make.right.equalTo(self.contentView.right).offset(-margin);
        make.centerX.equalTo(self.contentView.centerX);
        make.height.equalTo(self.videoContainer.width).multipliedBy(0.5625);
        make.top.equalTo(self.videoTitle.bottom).offset(margin);
        make.bottom.equalTo(self.contentView.bottom).offset(-margin);   // 通过底部约束实现cell行高自适应
    }];
    
    // playerVC
    [self.playerVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.top.equalTo(0);
        make.height.equalTo(self.videoContainer.height);
        make.width.equalTo(self.videoContainer.width);
    }];

}

// 计算label宽高
- (CGSize)sizeWithText:(NSString *)text andMaxSize:(CGSize)maxSize andFont:(UIFont *)font{
    NSDictionary *attr = @{NSFontAttributeName : font};
    return[text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
