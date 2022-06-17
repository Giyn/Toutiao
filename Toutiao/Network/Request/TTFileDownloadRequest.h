//
//  TTFileDownloadRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFileDownloadRequest : TTBaseRequest
@property (nonatomic, copy) NSString *fileId;
@end

NS_ASSUME_NONNULL_END
