//
//  TTUpdateUserInfoRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTRegisterRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTUpdateUserInfoRequest : TTRegisterRequest
@property (nonatomic, assign) NSInteger *picture;
@end

NS_ASSUME_NONNULL_END
