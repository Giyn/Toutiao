//
//  TTSearchData.h
//  Toutiao
//
//  Created by luo on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "../TTWorkRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchData : NSObject

@property (nonatomic, strong) NSArray <TTWorkRecord *> *records;

@end

NS_ASSUME_NONNULL_END
