//
//  TTLoginData.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTLoginData : NSObject
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *expireAt;
@end

NS_ASSUME_NONNULL_END
