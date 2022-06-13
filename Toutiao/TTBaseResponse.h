//
//  TTBaseResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTBaseResponse : NSObject
@property (nonatomic, copy) NSString *success;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *message;
@end

NS_ASSUME_NONNULL_END
