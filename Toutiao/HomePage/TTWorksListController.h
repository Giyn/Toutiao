//
//  TTWorksListController.h
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import <UIKit/UIKit.h>
@class TTAVPlayerView;
NS_ASSUME_NONNULL_BEGIN

@interface TTWorksListController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TTAVPlayerView *avPlayerView; // 视频播放器视图

@property (nonatomic, assign) BOOL isPlayerRemoved;
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath

//- (void)viewDidLoad;
- (void)setupView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)imglongTapClick:(UILongPressGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
