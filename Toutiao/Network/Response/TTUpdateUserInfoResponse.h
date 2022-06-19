//
//  TTUpdateUserInfoResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/17.
//

#import "TTBaseResponse.h"
#import "TTGetUserInfoData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTUpdateUserInfoResponse : TTBaseResponse
@property (nonatomic, strong) TTGetUserInfoData *data;
@end

NS_ASSUME_NONNULL_END
