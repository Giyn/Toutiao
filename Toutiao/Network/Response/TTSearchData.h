//
//  TTSearchData.h
//  Toutiao
//
//  Created by 吕文奎 on 2022/6/20.
//

#import <Foundation/Foundation.h>
#import "../../Model/TTWorkRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchData : NSObject

@property (nonatomic, strong) NSArray <TTWorkRecord *> *records;

@end

NS_ASSUME_NONNULL_END
