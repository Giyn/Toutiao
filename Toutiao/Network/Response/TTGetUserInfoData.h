//
//  TTGetUserInfoData.h
//  Toutiao
//
//  Created by 肖扬 on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "../TTWorkRecord.h"
#import "TTWorksListData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTGetUserInfoData : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, strong) NSString *pictureToken;
@property (nonatomic, strong) TTWorksListData *worksList;
@end

NS_ASSUME_NONNULL_END
