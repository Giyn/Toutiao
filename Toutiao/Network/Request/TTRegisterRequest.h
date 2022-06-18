//
//  TTRegisterRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTRegisterRequest : TTBaseRequest
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *name;
@end

NS_ASSUME_NONNULL_END
