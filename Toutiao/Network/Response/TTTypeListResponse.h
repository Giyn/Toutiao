//
//  TTTypeListResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/20.
//

#import "TTBaseResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTTypeListResponse : TTBaseResponse
@property (nonatomic, strong) NSArray <NSString *> *data;
@end

NS_ASSUME_NONNULL_END
