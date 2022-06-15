//
//  TTSearchModel.m
//  Toutiao
//
//  Created by luo on 2022/6/14.
//

#import "TTSearchModel.h"
#import "AFNetworking.h"

@implementation TTSearchModel
// 字典转模型
+ (instancetype)searchModelWithDic:(NSDictionary *)dic{
    TTSearchModel *searchModel = [self new];
    [searchModel setValuesForKeysWithDictionary:dic];
    return searchModel;
}

// 发送请求获取数据
+ (void)searchModelWithSuccess:(void(^)(NSArray *array))success error:(void(^)())error{
    
}

// 避免模型中数据存在空值
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
}

@end
