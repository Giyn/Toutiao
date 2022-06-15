//
//  TTSearchModel.h
//  Toutiao
//
//  Created by luo on 2022/6/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchModel : NSObject

@property (nonatomic, copy) NSString *imgIcon;  // 头像
@property (nonatomic, copy) NSString *usrName;  // 用户名
@property (nonatomic, copy) NSString *videoTitle;   // 视频标题
@property (nonatomic, copy) NSString *videoImg; // 视频图片

+ (instancetype)searchModelWithDic:(NSDictionary *)dic;   // 字典转模型
+ (void)searchModelWithSuccess:(void(^)(NSArray *array))success error:(void(^)())error;   // 发送请求获取数据

@end

NS_ASSUME_NONNULL_END
