//
//  TTSearchDataResponse.h
//  Toutiao
//
//  Created by 吕文奎 on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "TTSearchModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSearchDataResponse : NSObject

@property (nonatomic, copy) NSString *pictureToken;
@property (nonatomic, copy) NSString *videoToken;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uploader;
@property (nonatomic, copy) NSString *uploaderToken;

- (TTSearchModel *)getModel;

@end

NS_ASSUME_NONNULL_END
