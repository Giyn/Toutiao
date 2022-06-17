//
//  TTVideoStreamResponse.h
//  Toutiao
//
//  Created by Admin on 2022/6/15.
//

#import <Foundation/Foundation.h>
#import "TTBaseResponse.h"
#import "TTVideoData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVideoStreamResponse : TTBaseResponse

@property (nonatomic, strong) TTVideoData *data;

@end

NS_ASSUME_NONNULL_END
