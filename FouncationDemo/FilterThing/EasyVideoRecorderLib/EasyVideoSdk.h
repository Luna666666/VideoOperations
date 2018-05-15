//
//  EasyVideoSdk.h
//  EasyVideoRecorder
//
//  Created by chenshun on 16/3/16.
//  Copyright © 2016年 EasyDarwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

#define kThirdParty 0

@interface EasyVideoSdk : NSObject

+ (NSString *)sdkVersion;

+ (id)startupWithKey:(NSString *)key error:(NSInteger *)error;
+ (BOOL)isInitSuccess;

+ (void)setTinColor:(UIColor *)tinColor;

@end
