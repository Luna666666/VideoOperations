//
//  Emember.m
//  Nplan
//
//  Created by swkj on 16/6/20.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "Emember.h"
#import "Unity.h"
@implementation Emember

+(instancetype)init:(NSDictionary *)dic{
    return [[Emember alloc]initWithDic:dic];
    
}
- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
     self.UId= [Unity ToString:dic[@"uId"]];
     self.PNo= [Unity ToString:dic[@"pNo"]];
     self.PerImg=[Unity ToString:dic[@"perImg"]];
     self.PerName=[Unity ToString:dic[@"perName"]];
     self.Sex=[Unity ToString:dic[@"sex"]];
     self.NId=[Unity ToString:dic[@"nId"]];
     self.NaId=[Unity ToString:dic[@"naId"]];
     self.ProvinceId=[Unity ToString:dic[@"provinceId"]];
     self.CityId=[Unity ToString:dic[@"cityId"]];
     self.Height=[Unity ToString:dic[@"height"]];
     self.Weight=[Unity ToString:dic[@"weight"]];
     self.AgeStage=[Unity ToString:dic[@"ageStage"]];
     self.PerType=[Unity ToString:dic[@"perType"]];
     self.IsRecommend=[Unity ToString:dic[@"isRecommend"]];
     self.DisplayOrder=[Unity ToString:dic[@"displayOrder"]];
     self.IsIDCard=[Unity ToString:dic[@"IDCard"]];
     self.Age=[Unity ToString:dic[@"age"]];
     self.WorkAdd=[Unity ToString:dic[@"workAdd"]];
     self.ParentName=[Unity ToString:dic[@"parentName"]];
     self.ParentTel=[Unity ToString:dic[@"parentTel"]];
     self.Mobile=[Unity ToString:dic[@"mobile"]];
     self.Tel=[Unity ToString:dic[@"tel"]];
     self.UserQQ=[Unity ToString:dic[@"QQ"]];
     self.WeChat=[Unity ToString:dic[@"weChat"]];
     self.Zip=[Unity ToString:dic[@"zip"]];
     self.Address=[Unity ToString:dic[@"address"]];
     self.PerState=[Unity ToString:dic[@"perState"]];
     self.ArtSpeList=[Unity ToString:dic[@"artSpeList"]];
     self.EduEducationList=[Unity ToString:dic[@"eduEducationList"]];
     self.CertificateList=[Unity ToString:dic[@"certificateList"]];
     self.AchievementList=[Unity ToString:dic[@"achievementList"]];
     self.EitTime=[Unity ToString:dic[@"eitTime"]];
     self.AddTime=[Unity ToString:dic[@"addTime"]];
     self.RecPerson=[Unity ToString:dic[@"recPerson"]];
     self.Nationality=[Unity ToString:dic[@"nationality"]];
     self.Nation=[Unity ToString:dic[@"nation"]];
     self.Province=[Unity ToString:dic[@"province"]];
     self.City=[Unity ToString:dic[@"city"]];
     self.ArtSpe_List=[Unity ToArray:dic[@"artSpe_List"]];
     self.EduEducation_List=[Unity ToArray:dic[@"eduEducation_List"]];
     self.Certificate_List=[Unity ToArray:dic[@"certificate_List"]];
     self.Achievement_List=[Unity ToArray:dic[@"achievement_List"]];
    
}
    return self;
}
@end
