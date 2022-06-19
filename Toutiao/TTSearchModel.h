//
//  TTSearchModel.h
//  Toutiao
//
//  Created by luo on 2022/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchModel : NSObject

@property (nonatomic, copy) NSString *imgIcon;  // 头像
@property (nonatomic, copy) NSString *usrName;  // 用户名
@property (nonatomic, copy) NSString *videoTitle;   // 视频标题
@property (nonatomic, copy) NSString *videoImg; // 视频图片
@property (nonatomic, copy) NSString *video;    // 视频

+ (void)searchModelWithSuccess:(void(^)(NSArray *array))success fail:(void(^)(NSError *error))fail text:(NSString *)text current:(NSNumber *)current;   // 发送请求获取数据

@end

NS_ASSUME_NONNULL_END
