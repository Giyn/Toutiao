//
//  TTSearchTableViewCell.h
//  Toutiao
//
//  Created by Admin on 2022/6/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchTableViewCell : UITableViewCell

@property (nonatomic, weak) UIImageView *imgViewIcon;
@property (nonatomic, weak) UILabel *usrName;
@property (nonatomic, weak) UILabel *videoTitle;
@property (nonatomic, weak) UIView *videoContainer;

- (void) settingFrame;  // 设置控件位置的方法
@end

NS_ASSUME_NONNULL_END
