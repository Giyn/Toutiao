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

@property (nonatomic, assign) BOOL isFromSearch;
@property (nonatomic, assign) BOOL isPlayerRemoved;
@property (nonatomic, assign) NSInteger currentIndex; // 当前tableview的indexPath

@end

NS_ASSUME_NONNULL_END
