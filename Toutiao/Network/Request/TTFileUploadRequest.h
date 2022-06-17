//
//  TTFileUploadRequest.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFileUploadRequest : TTBaseRequest
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSData *fileData;
@end

NS_ASSUME_NONNULL_END
