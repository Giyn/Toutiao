//
//  TTNetworkManager.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "URLs.h"

typedef NS_ENUM(NSInteger, TTHttpMethodType) {
    TTHttpMethodTypeGET,
    TTHttpMethodTypePOST,
    TTHttpMethodTypePUT,
    TTHttpMethodTypeDELETE
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnProgress)(NSProgress *progress);
typedef void(^OnSuccess)(id responseObject);
typedef void(^OnError)(NSError *error);

@interface TTNetworkTool : AFHTTPSessionManager

+ (instancetype)sharedManager;

// 将fileToken拼接成filePath(不包含baseURL)
+ (NSString *)getDownloadPathWithFileToken:(NSString *)fileToken;

// 将fileToken拼接成URLString(包含baseURL)
+ (NSString *)getDownloadURLWithFileToken:(NSString *)fileToken;

- (void)requestWithMethod:(TTHttpMethodType)method
                     path:(NSString *)path
                   params:(NSDictionary*)params
            requiredToken:(BOOL)requiredToken
                onSuccess:(OnSuccess)onSuccess
                  onError:(OnError)onError
               onProgress:(_Nullable OnProgress)onProgress;

@end


NS_ASSUME_NONNULL_END
