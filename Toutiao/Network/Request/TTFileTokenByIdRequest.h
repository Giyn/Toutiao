//
//  TTFileDownloadRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFileTokenByIdRequest : TTBaseRequest
@property (nonatomic, assign) NSInteger fileId;
@end

NS_ASSUME_NONNULL_END
