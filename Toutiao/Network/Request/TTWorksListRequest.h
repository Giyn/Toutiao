//
//  TTWorksListRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTWorksListRequest : TTBaseRequest
@property (nonatomic, assign) NSInteger current;
@property (nonatomic, assign) NSInteger size;
@end

NS_ASSUME_NONNULL_END
