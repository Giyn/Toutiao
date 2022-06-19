//
//  TTVideoStreamController.h
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import <UIKit/UIKit.h>
@class TTAVPlayerView;
NS_ASSUME_NONNULL_BEGIN

@interface TTVideoStreamController : UIViewController

@property (nonatomic, strong) NSMutableArray *videoImgArray; // 视频第一帧图片
@property (nonatomic, strong) NSArray *urlArray; // 存放视频url
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TTAVPlayerView *avPlayerView; // 视频播放器视图
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath

//@property (nonatomic, assign) BOOL isFromSearch;
//@property (nonatomic, copy) NSString *searchText;

//- (void)viewDidLoad;
- (void)setupView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)imglongTapClick:(UILongPressGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
