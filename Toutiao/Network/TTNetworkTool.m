//
//  TTNetworkManager.m
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "AFHTTPSessionManager.h"
#import "MJExtension.h"
#import "URLs.h"
#import "TTNetworkTool.h"
#import "Request/TTFileUploadRequest.h"

@implementation TTNetworkTool

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TTNetworkTool *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]initWithBaseURL:[NSURL URLWithString:baseURLString]];
    });
    return manager;
}

+ (NSString *)getDownloadPathWithFileToken:(NSString *)fileToken {
    return [NSString stringWithFormat:@"%@%@", getFileByFileTokenPath, fileToken];
}

+ (NSString *)getDownloadURLWithFileToken:(NSString *)fileToken {
    return [NSString stringWithFormat:@"%@%@%@", baseURLString, getFileByFileTokenPath, fileToken];
}

- (void)requestWithMethod:(TTHttpMethodType)method path:(NSString *)path params:(NSDictionary *)params requiredToken:(BOOL)requiredToken onSuccess:(OnSuccess)onSuccess onError:(OnError)onError onProgress:(OnProgress)onProgress {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    

    switch (method) {
        case TTHttpMethodTypeGET: {
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            if (requiredToken) {
                NSString *token = [defaults objectForKey:@"token"];
                [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
            }
            [self GET:path parameters:params progress:onProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                onSuccess(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                onError(error);
            }];
            break;
        }
        case TTHttpMethodTypePOST: {
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            if (requiredToken) {
                NSString *token = [defaults objectForKey:@"token"];
                [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
            }
            if ([path isEqualToString:fileUploadPath]) {
                TTFileUploadRequest *body = [TTFileUploadRequest mj_objectWithKeyValues:params];
                [self POST:fileUploadPath parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    [formData appendPartWithFileData:body.fileData name:@"multipartFile" fileName:body.fileName mimeType:@"*/*"];
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    onProgress(uploadProgress);
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    onSuccess(responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    onError(error);
                }];
            } else {
                [self POST:path parameters:params progress:onProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    onSuccess(responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    onError(error);
                }];
            }
            
            break;
        }
        case TTHttpMethodTypePUT: {
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            if (requiredToken) {
                NSString *token = [defaults objectForKey:@"token"];
                [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
            }
            [self PUT:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                onSuccess(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                onError(error);
            }];
            break;
        }
        case TTHttpMethodTypeDELETE: {
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            if (requiredToken) {
                NSString *token = [defaults objectForKey:@"token"];
                [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
            }
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
