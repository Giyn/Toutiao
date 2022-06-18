//
//  TTBaseResponse.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTBaseResponse : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, assign, getter=isSuccess) BOOL success;
@end

NS_ASSUME_NONNULL_END
