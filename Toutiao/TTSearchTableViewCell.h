//
//  TTSearchTableViewCell.h
//  Toutiao
//
//  Created by Admin on 2022/6/10.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TTSearchModel;
@interface TTSearchTableViewCell : UITableViewCell

@property (nonatomic, weak) UIImageView *imgViewIcon;   // 头像
@property (nonatomic, weak) UILabel *usrName;   // 用户名
@property (nonatomic, weak) UILabel *videoTitle;    // 视频标题

@property (nonatomic, strong) UIImageView *videoImgView;    // 视频图片
- (void) settingFrame;  // 设置控件位置的方法

@end

NS_ASSUME_NONNULL_END
