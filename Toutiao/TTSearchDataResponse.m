//
//  TTSearchDataResponse.m
//  Toutiao
//
//  Created by 吕文奎 on 2022/6/17.
//

#import "TTSearchDataResponse.h"
#import "AFHTTPSessionManager.h"

@implementation TTSearchDataResponse

- (TTSearchModel *)getModel{
    NSString *download = @"http://47.96.114.143:62318/api/file/download/";
    NSString *imgIcon = [download stringByAppendingString:self.uploaderToken];
    NSString *videoImg = [download stringByAppendingString:self.pictureToken];
    NSString *video = [download stringByAppendingString:self.videoToken];
    
    TTSearchModel *model = [[TTSearchModel alloc] init];
    model.imgIcon = imgIcon;
    model.usrName = self.uploader;
    model.videoTitle = self.name;
    model.videoImg = videoImg;
    model.video = video;
    
    return model;
}

@end
