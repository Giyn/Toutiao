//
//  TTFileUploadResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTBaseResponse.h"
#import "TTFileUploadData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTFileUploadResponse : TTBaseResponse
@property (nonatomic, strong) TTFileUploadData *data;
@end

NS_ASSUME_NONNULL_END
