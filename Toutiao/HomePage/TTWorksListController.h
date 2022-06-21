//
//  TTWorksListController.h
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import <UIKit/UIKit.h>
#import "TTAVPlayerView.h"
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface TTWorksListController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TTAVPlayerView *avPlayerView; // 视频播放器视图

@property (nonatomic, assign) BOOL isPlayerRemoved;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL hasAddObserver;
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath
@property (nonatomic, assign) NSInteger pageIndex; // 当前视频数据的页索引

//- (void)viewDidLoad;
- (void)setupView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)imglongTapClick:(UILongPressGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
