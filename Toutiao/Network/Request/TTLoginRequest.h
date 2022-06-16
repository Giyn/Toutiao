//
//  TTLoginRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTLoginRequest : TTBaseRequest
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@end

NS_ASSUME_NONNULL_END
