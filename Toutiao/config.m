//
//  config.m
//  Toutiao
//
//  Created by 肖扬 on 2022/6/13.
//

#import <Foundation/Foundation.h>

NSString *const kUsernameRegex = @"[A-Za-z0-9]+";
NSString *const kEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
NSString *const kPasswordRegex = @"(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}";
const NSUInteger kValidPasswordLength = 30;

