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
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, TTHttpMethodType) {
    TTHttpMethodTypeGET,
    TTHttpMethodTypePOST,
    TTHttpMethodTypePUT,
    TTHttpMethodTypeDELETE
};
typedef void(^OnProgress)(CGFloat percentage);
typedef void(^OnSuccess)(id responseObject);
typedef void(^OnError)(NSError *error);
@interface TTNetworkTool : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (void)requestWithMethod:(TTHttpMethodType)method
                     path:(NSString *)path
                   params:(NSDictionary*)params
            requiredToken:(BOOL)requiredToken
                onSuccess:(OnSuccess)onSuccess
                  onError:(OnError)onError;

@end


NS_ASSUME_NONNULL_END
