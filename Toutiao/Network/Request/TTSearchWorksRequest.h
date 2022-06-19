//
//  TTSearchWorksRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/17.
//

#import "TTWorksListRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchWorksRequest : TTWorksListRequest
@property (nonatomic, copy) NSString *searchString;
@end

NS_ASSUME_NONNULL_END
