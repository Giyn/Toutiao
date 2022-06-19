//
//  TTWorksListResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseResponse.h"
#import "TTWorksListData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTWorksListResponse : TTBaseResponse
@property (nonatomic, strong) TTWorksListData *data;
@end

NS_ASSUME_NONNULL_END
