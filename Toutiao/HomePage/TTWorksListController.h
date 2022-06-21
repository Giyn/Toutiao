//
//  TTWorksListController.h
//  Toutiao
//
//  Created by Giyn on 2022/6/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTWorksListController : UIViewController

@property (nonatomic, assign) BOOL isFromSearch;
@property (nonatomic, assign) BOOL isPlayerRemoved;
@property (nonatomic, assign) BOOL isScrollUp; // 是否向上滑动
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath
@property (nonatomic, assign) NSInteger pageIndex; // 当前视频数据的页索引

@end

NS_ASSUME_NONNULL_END
