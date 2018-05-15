//
//  UserMainInfo.m
//  DamiOA
//
//  Created by ZhouLord on 15/3/30.
//  Copyright (c) 2015年 ZhouLord. All rights reserved.
//

#import "MainUserInfo.h"

static MainUserInfo *mainUserInfo;
@implementation MainUserInfo

+(MainUserInfo *)shareInfo{
    if (!mainUserInfo) {
        mainUserInfo=[[MainUserInfo alloc]init];
    }
    return mainUserInfo;
}

@end


static APPInfo *appInfo;
@implementation APPInfo

+(NSString *)path{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"UserAppInfo.plist"];
}

+(APPInfo *)shareInfo{
    if (!appInfo) {
        appInfo=[NSKeyedUnarchiver unarchiveObjectWithFile:[APPInfo path]];
        if (!appInfo)
            appInfo=[[APPInfo alloc]initWithCoder:nil];
    }
    return appInfo;
}

+(void)Save{
    [NSKeyedArchiver archiveRootObject:appInfo toFile:[APPInfo path]];
}

+(void)releaseInfo{
    appInfo.password=@"";
    appInfo.pNo = nil;
    appInfo.cuId = nil;
    appInfo.perType = nil;
    appInfo.perName = @"";
    appInfo.perImg = @"";
    appInfo.realName = @"";
    appInfo.userNumName = @"";
    appInfo.uId = nil;
    appInfo.HTTPHeader = nil;
    appInfo.rongCloudToken = nil;
    [APPInfo Save];
    mainUserInfo=nil;
}
//解码
- (id) initWithCoder: (NSCoder *)coder{
    if (self = [super init]){
        
        
        
        if (coder) {
            
            self.AppVersion =[coder decodeObjectForKey:@"AppVersion"];
            self.cuId = [coder decodeObjectForKey:@"cuId"];
            self.perType =  [coder decodeObjectForKey:@"perType"];
            self.account =[coder decodeObjectForKey:@"account"];
            self.password =[coder decodeObjectForKey:@"password"];
            self.uId = [coder decodeObjectForKey:@"uId"];
            self.pNo = [coder decodeObjectForKey:@"pNo"];
            self.perImg = [coder decodeObjectForKey:@"perImg"];
            self.perName = [coder decodeObjectForKey:@"perName"];
            self.HTTPHeader = [coder decodeObjectForKey:@"HTTPHeader"];
            self.rongCloudToken = [coder decodeObjectForKey:@"rongCloudToken"];
            self.userNumName = [coder decodeObjectForKey:@"userNumName"];
            self.realName = [coder decodeObjectForKey:@"realName"];
        }else{
            self.realName = @"";
            self.cuId = nil;
            self.perType = nil;
            self.userNumName = @"";
            self.AppVersion =@"";
            self.account =@"";
            self.password =@"";
            self.pNo = nil;
            self.perName = @"";
            self.perImg = @"";
            self.uId = nil;
            self.HTTPHeader = nil;
            self.rongCloudToken = nil;
            NSString *path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/data"];
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            [[NSURL fileURLWithPath:path]setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
        }
    }
    return self;
}
//编码
- (void) encodeWithCoder: (NSCoder *)coder{
    [coder encodeObject:_AppVersion forKey:@"AppVersion"];
    [coder encodeObject:_cuId forKey:@"cuId"];
    [coder encodeObject:_perType forKey:@"perType"];
    [coder encodeObject:_account forKey:@"account"];
    [coder encodeObject:_password forKey:@"password"];
    [coder encodeObject:_perImg forKey:@"perImg"];
    [coder encodeObject:_perName forKey:@"perName"];
    [coder encodeObject:_pNo forKey:@"pNo"];
    [coder encodeObject:_uId forKey:@"uId"];
    [coder encodeObject:_HTTPHeader forKey:@"HTTPHeader"];
    [coder encodeObject:_rongCloudToken forKey:@"rongCloudToken"];
    [coder encodeObject:_realName forKey:@"realName"];
    [coder encodeObject:_userNumName forKey:@"userNumName"];
    
}

@end
