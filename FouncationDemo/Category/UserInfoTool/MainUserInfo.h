//
//  UserMainInfo.h
//  DamiOA
//
//  Created by ZhouLord on 15/3/30.
//  Copyright (c) 2015年 ZhouLord. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Emember.h"
#import "BaseInfo.h"
@interface MainUserInfo : NSObject

@property(nonatomic)Emember *Member;
@property(nonatomic)BaseInfo * baseInfo;

+(MainUserInfo *)shareInfo;

@end


@interface APPInfo : NSObject

@property(nonatomic)NSString *AppVersion;//验证是否首次安装
@property(nonatomic,copy)NSString * cuId;
@property(nonatomic,copy)NSString * perType;//用户类型
@property(nonatomic,copy)NSString *account;//账户
@property(nonatomic,copy)NSString *password;//密码
@property(nonatomic,copy)NSString * uId;//用户id
@property(nonatomic,copy)NSString * userNumName;//用户id
@property(nonatomic,copy)NSString * realName;//用户id
@property(nonatomic,copy)NSString * pNo;//艺人编号
@property(nonatomic,copy)NSString * perName;//用户名称
@property(nonatomic,copy)NSString * perImg;//用户头像图
@property(nonatomic,copy)NSDictionary * HTTPHeader;//请求头
@property(nonatomic,copy)NSString * perAir;//人气
@property(nonatomic,copy)NSString * rongCloudToken;//荣云的token
+(APPInfo *)shareInfo;
+(void)releaseInfo;
+(void)Save;

@end


