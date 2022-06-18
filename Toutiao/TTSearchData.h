//
//  TTSearchData.h
//  Toutiao
//
//  Created by 吕文奎 on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "TTSearchDataResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchData : NSObject

@property (nonatomic, strong) NSArray<TTSearchDataResponse *> *records;

@end

NS_ASSUME_NONNULL_END
