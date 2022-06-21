

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTUserInfoCell : UITableViewCell
@property (nonatomic, weak) UILabel *videoTitle;    // 视频标题
@property (nonatomic, strong) UIImageView *videoImgView;    // 视频图片
- (void) settingFrame;  // 设置控件位置的方法
@end

NS_ASSUME_NONNULL_END

