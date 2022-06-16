//
//  TTLoginData.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/13.
//

#import <Foundation/Foundation.h>
#import "TTUserData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTLoginData : NSObject
@property (nonatomic, strong) TTUserData *user;
@property (nonatomic, copy)   NSString *token;
@property (nonatomic, copy)   NSArray<NSString *> *permissionList;
@property (nonatomic, assign) NSInteger expireAt;
@end

NS_ASSUME_NONNULL_END
