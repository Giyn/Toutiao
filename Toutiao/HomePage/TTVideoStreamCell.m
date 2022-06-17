//
//  TTVideoStreamCell.m
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import "TTVideoStreamCell.h"
#import "config.h"

@implementation TTVideoStreamCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor blackColor];

        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTabBarHeight)];
        self.bgImageView.tag = 100;
        self.bgImageView.image = [UIImage imageNamed:@"video_loading"];
        [self.contentView addSubview:self.bgImageView];

        self.middleView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth-80, (kScreenHeight-150-kStatusHeight)/2, 80, 50)];
        self.middleView.tag = 200;
        [self.contentView addSubview:self.middleView];
    }

    return self;
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
