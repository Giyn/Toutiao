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
//@property (nonatomic, weak) UIButton *btn1;
//@property (nonatomic, weak) UIButton *btn2;
//@property (nonatomic, weak) UIButton *btn3;
- (void) settingFrame;

@end

NS_ASSUME_NONNULL_END
