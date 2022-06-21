//
//  TTWorksListData.m
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import "TTWorksListData.h"
#import "MJExtension.h"

@implementation TTWorksListData

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"records": TTWorkRecord.class};
}

@end
