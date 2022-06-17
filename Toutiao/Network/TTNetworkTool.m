//
//  TTNetworkManager.m
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTNetworkTool.h"
#import "MJExtension.h"

@implementation TTNetworkTool

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TTNetworkTool *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]initWithBaseURLString:baseURLString];
    });
    return manager;
}

- (instancetype)initWithBaseURLString:(NSString *)baseURLString {
    self = [self initWithBaseURL:[NSURL URLWithString:baseURLString]];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer = requestSerializer;
    }
    return self;
}

- (void)requestWithMethod:(TTHttpMethodType)method path:(NSString *)path params:(NSDictionary *)params requiredToken:(BOOL)requiredToken onSuccess:(OnSuccess)onSuccess onError:(OnError)onError {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *headers = @{}.mutableCopy;
    if (requiredToken) {
        NSString *token = [defaults objectForKey:@"token"];
        headers[@"Authorization"] = token;
    }
    
    NSLog(@"header: %@, params: %@", headers, params);
    switch (method) {
        case TTHttpMethodTypeGET: {
            [self GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                onSuccess(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                onError(error);
            }];
            break;
        }
        case TTHttpMethodTypePOST: {
            [self.requestSerializer requestWithMethod:@"POST" URLString:loginPath parameters:params error:nil];
            [self POST:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                onSuccess(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                onError(error);
            }];
            break;
        }
        case TTHttpMethodTypePUT: {
            [self PUT:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                onSuccess(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                onError(error);
            }];
            break;
        }
        case TTHttpMethodTypeDELETE: {
            [self DELETE:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                onSuccess(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                onError(error);
            }];
            break;
        }
    }
}




@end
