
#import "TTUserInfoCell.h"
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

#define videoTitleFont [UIFont systemFontOfSize:18]
#define heightToWidth 0.5625

@implementation TTUserInfoCell
// 重写cell初始化方法
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        // 3 视频标题
        UILabel *videoTitle = [[UILabel alloc] init];
        videoTitle.font = videoTitleFont;
        videoTitle.numberOfLines = 1;   // 显示2行后自动换行
        [self.contentView addSubview:videoTitle];
        self.videoTitle = videoTitle;
        
        // 视频图片
        self.videoImgView = [[UIImageView alloc] init];
        self.videoImgView.backgroundColor = [UIColor blackColor];
        self.videoImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.videoImgView];
        
    }
    return self;
}

#pragma mark - 控件布局
// 设置cell中控件的位置
- (void)settingFrame{
    // 统一间距
    CGFloat margin = 10;
    // 视频标题
    [self.videoTitle makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.left).offset(margin);
        make.top.equalTo(self.contentView.top).offset(margin);
    }];
    
    // 视频图片
    [self.videoImgView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoTitle.left);
        make.right.equalTo(self.contentView.right).offset(-margin);
        make.centerX.equalTo(self.contentView.centerX);
        make.height.equalTo(self.videoImgView.width).multipliedBy(0.5625);
        make.top.equalTo(self.videoTitle.bottom).offset(margin);
        make.bottom.equalTo(self.contentView.bottom).offset(-margin);   // 通过底部约束实现cell行高自适应
    }];
    
    // 更新view中的frame
    [self.contentView layoutIfNeeded];
    CGSize titleSize = [self sizeWithText:self.videoTitle.text andMaxSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*margin, MAXFLOAT) andFont:videoTitleFont]; //动态计算宽高
    self.videoTitle.bounds = CGRectMake(0, 0, titleSize.width, titleSize.height);
    
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
