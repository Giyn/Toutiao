//
//  TTUserData.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import <Foundation/Foundation.h>
#import "TTUserData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTUserData : NSObject
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy)   NSString *account;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *mail;
@property (nonatomic, copy)   NSString *pictureToken;
@end

NS_ASSUME_NONNULL_END
