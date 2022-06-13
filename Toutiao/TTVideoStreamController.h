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
@property (nonatomic, strong) TTAVPlayerView *avPlayerView; // 视频播放器视图
@end

NS_ASSUME_NONNULL_END
