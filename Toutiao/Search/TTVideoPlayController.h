//
//  TTVideoPlayController.h
//  Toutiao
//
//  Created by luo on 2022/6/20.
//

#import "TTWorksListController.h"
#import "TTWorksListCell.h"
#import "TTAVPlayerView.h"
#import <Foundation/Foundation.h>
#import "config.h"
#import "TTSearchModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShortMediaResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVideoPlayController : TTWorksListController

@property (nonatomic, copy) NSString *searchText;

@end

NS_ASSUME_NONNULL_END
