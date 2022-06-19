//
//  TTFileUploadData.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTFileUploadData : NSObject
@property (nonatomic, assign) NSInteger fileID;
@property (nonatomic, assign) NSInteger thumbnailFileID;
@property (nonatomic, copy)   NSString *contentType;
@property (nonatomic, copy)   NSString *fileToken;
@end

NS_ASSUME_NONNULL_END
