//
//  TTWorksListByTypeRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/20.
//

#import "TTWorksListRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTWorksListByTypeRequest : TTWorksListRequest
@property (nonatomic, copy) NSString *type;
@end

NS_ASSUME_NONNULL_END
