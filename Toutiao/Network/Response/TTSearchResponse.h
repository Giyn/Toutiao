//
//  TTSearchResponse.h
//  Toutiao
//
//  Created by luo on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "TTBaseResponse.h"
#import "TTSearchData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchResponse : TTBaseResponse

@property(nonatomic, strong) TTSearchData *data;

@end

NS_ASSUME_NONNULL_END
