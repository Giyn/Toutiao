//
//  TTSearchModel.m
//  Toutiao
//
//  Created by luo on 2022/6/17.
//

#import "TTSearchModel.h"
#import "AFHTTPSessionManager.h"
#import "TTSearchResponse.h"
#import <MJExtension/NSObject+MJKeyValue.h>

#import "../Network/TTNetworkTool.h"
#import "../Network/URLs.h"
#import "../Network/TTWorkRecord.h"
#import "../Network/Request/TTSearchWorksRequest.h"

@implementation TTSearchModel
// 获取token
+ (NSString *) getUserToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    return token;
}

+ (void)searchModelWithSuccess:(void(^)(NSArray *array))success fail:(void(^)(NSError *error))fail text:(NSString *)text current:(NSInteger)current size:(NSInteger)size{
    
    TTSearchWorksRequest *request = [[TTSearchWorksRequest alloc] init];
    request.current = current;
    request.size = size;
    request.searchString = text;
    NSDictionary *params = [request mj_keyValues].copy;
    
    TTNetworkTool *manager = [TTNetworkTool sharedManager];
    [manager requestWithMethod:TTHttpMethodTypeGET path:searchWorksPath params:params requiredToken:YES onSuccess:^(id  _Nonnull responseObject) {
        
        TTSearchResponse *searchResponse = [TTSearchResponse mj_objectWithKeyValues:responseObject];
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in searchResponse.data.records){
            TTWorkRecord *record = [TTWorkRecord mj_objectWithKeyValues:dic];
            TTSearchModel *model = [TTSearchModel getModelWithRecord:record];
            [models addObject:model];
        }
        if(success){
            success(models.copy);
        }
    } onError:^(NSError * _Nonnull error) {
        if(fail){
            fail(error);    // 错误则返回error
        }
    } onProgress:nil];
}

+ (TTSearchModel *)getModelWithRecord:(TTWorkRecord *)record {
    NSString *imgIcon = [TTNetworkTool getDownloadURLWithFileToken:record.uploaderToken];
    NSString *videoImg =[TTNetworkTool getDownloadURLWithFileToken:record.pictureToken];
    NSString *video = [TTNetworkTool getDownloadURLWithFileToken:record.videoToken];
    
    TTSearchModel *model = [[TTSearchModel alloc] init];
    model.imgIcon = imgIcon;
    model.usrName = record.uploader;
    model.videoTitle = record.name;
    model.videoImg = videoImg;
    model.video = video;
    
    return model;
}
@end
