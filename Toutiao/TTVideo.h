//
//  TTVideo.h
//  Toutiao
//
//  Created by Admin on 2022/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTVideo : NSObject

@property (nonatomic, copy) NSString *videoToken;
@property (nonatomic, copy) NSString *pictureToken;
@property (nonatomic, copy) NSString *uploader;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
