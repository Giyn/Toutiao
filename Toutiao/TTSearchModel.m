//
//  TTSearchModel.m
//  Toutiao
//
//  Created by luo on 2022/6/17.
//

#import "TTSearchModel.h"
#import "AFHTTPSessionManager.h"
#import "TTSearchResponse.h"
#import <MJExtension/NSObject+MJKeyValue.h>

@implementation TTSearchModel
// 获取token
+ (NSString *) getUserToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    return token;
}

+ (void)searchModelWithSuccess:(void(^)(NSArray *array))success fail:(void(^)(NSError *error))fail text:(NSString *)text current:(NSNumber *)current{
    // 获取token
    NSString *token = [self getUserToken];
    //NSInteger current = 1;  // 当前页
    NSInteger size = 10;    // 页大小
    NSString *url = @"http://47.96.114.143:62318/api/works/searchWorks";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 设置序列
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    // 设置请求头
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    // 设置参数
    NSDictionary *parametersDic = @{@"current":current, @"size":[NSNumber numberWithInt:(int)size], @"searchString":text};

    // 发起请求
    [manager GET:url parameters:parametersDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TTSearchResponse *searchResponse = [TTSearchResponse mj_objectWithKeyValues:responseObject];
        //NSLog(@"responseObject%@, searchResponse%@",responseObject,searchResponse);
        //NSLog(@"searchResponse.data.records%@",searchResponse.data.records);    // records是一个数组 里面存搜到的作品字典  (字典数组)
        
        NSArray *recordsArray = [[TTSearchDataResponse mj_objectArrayWithKeyValuesArray:searchResponse.data.records] copy];    // 字典数组转化为模型数组(token)
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for(TTSearchDataResponse *dataResponse in recordsArray){
            TTSearchModel *model = [dataResponse getModel];
            [models addObject:model];
            }
        if(success){
            success(models.copy);
        }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(fail){
                fail(error);    // 错误则返回error
            }
    }];
}

@end
