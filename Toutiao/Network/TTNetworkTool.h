//
//  TTNetworkManager.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "URLs.h"
#import "Request/TTBaseRequest.h"

typedef NS_ENUM(NSInteger, TTHttpMethodType) {
    TTHttpMethodTypeGET,
    TTHttpMethodTypePOST,
    TTHttpMethodTypePUT,
    TTHttpMethodTypeDELETE
};
typedef void(^OnProgress)(NSProgress * _Nullable progress);
typedef void(^OnSuccess)(id responseObject);
typedef void(^OnError)(NSError * _Nullable error);
NS_ASSUME_NONNULL_BEGIN

@interface TTNetworkTool : AFHTTPSessionManager

+ (instancetype)sharedManager;

+ (NSString *)getDownloadPathWithFileToken:(NSString *)fileToken; /// 将fileToken拼接成filePath(不包含baseURL)

+ (NSString *)getDownloadURLWithFileToken:(NSString *)fileToken; /// 将fileToken拼接成URLString(包含baseURL)

- (void)requestWithMethod:(TTHttpMethodType)method
                     path:(NSString *)path
                   params:(NSDictionary*)params
            requiredToken:(BOOL)requiredToken
                onSuccess:(OnSuccess)onSuccess
                  onError:(OnError)onError
               onProgress:(OnProgress)onProgress;

@end


NS_ASSUME_NONNULL_END
