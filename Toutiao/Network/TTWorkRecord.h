//
//  TTWorkRecord.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTWorkRecord : NSObject
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy)   NSString *pictureToken;
@property (nonatomic, copy)   NSString *videoToken;
@property (nonatomic, copy)   NSString *uploader;
@property (nonatomic, copy)   NSString *uploaderToken;
@property (nonatomic, copy)   NSString *name;
@end

NS_ASSUME_NONNULL_END
