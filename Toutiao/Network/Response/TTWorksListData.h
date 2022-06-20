//
//  TTWorksListData.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import <Foundation/Foundation.h>
#import "TTWorkRecord.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTWorksListData : NSObject
@property (nonatomic, strong) NSArray <TTWorkRecord *> *records;
@property (nonatomic, copy) NSString *total;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSInteger current;

@end

NS_ASSUME_NONNULL_END
