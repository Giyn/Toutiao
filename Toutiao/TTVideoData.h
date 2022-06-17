//
//  TTVideoData.h
//  Toutiao
//
//  Created by Admin on 2022/6/16.
//

#import <Foundation/Foundation.h>
#import "TTVideoResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVideoData : NSObject

@property (nonatomic, strong) NSArray<TTVideoResponse *> *records;

@end

NS_ASSUME_NONNULL_END
