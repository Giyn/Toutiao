//
//  TTSearchModel.h
//  Toutiao
//
//  Created by 吕文奎 on 2022/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchModel : NSObject

@property (nonatomic, copy) NSString *imgIcon;  // 头像
@property (nonatomic, copy) NSString *usrName;  // 用户名
@property (nonatomic, copy) NSString *videoTitle;   // 视频标题
@property (nonatomic, copy) NSString *videoImg; // 视频图片
@property (nonatomic, copy) NSString *video;    // 视频

@end

NS_ASSUME_NONNULL_END
