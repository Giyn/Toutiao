//
//  TTLoginResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/13.
//

#import "TTBaseResponse.h"
#import "TTLoginData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTLoginResponse : TTBaseResponse
@property (nonatomic, strong) TTLoginData *data;
@end

NS_ASSUME_NONNULL_END
