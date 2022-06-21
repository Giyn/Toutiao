//
//  TTSearchWorksResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/20.
//

#import "TTBaseResponse.h"
#import "TTSearchData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchResponse : TTBaseResponse

@property(nonatomic, strong) TTSearchData *data;

@end

NS_ASSUME_NONNULL_END
