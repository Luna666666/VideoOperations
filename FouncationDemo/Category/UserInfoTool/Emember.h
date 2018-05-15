//
//  Emember.h
//  Nplan
//
//  Created by swkj on 16/6/20.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Emember : NSObject
@property(nonatomic,strong)NSString *UId;//登录用户id，（int型）
@property(nonatomic,strong)NSString *PNo;//艺人编号（string 型）
@property(nonatomic,strong)NSString *PerImg;//头像
@property(nonatomic,strong)NSString *PerName;//艺人姓名（string 型）
@property(nonatomic,strong)NSString *Sex;//性别（int型）1：男；0：女；
@property(nonatomic,strong)NSString *NId;//国籍（int型）
@property(nonatomic,strong)NSString *NaId;//民族（int型）
@property(nonatomic,strong)NSString *ProvinceId;//省id（int型）
@property(nonatomic,strong)NSString *CityId;//市id（int型）
@property(nonatomic,strong)NSString *Height;//身高（float型）+
@property(nonatomic,strong)NSString *Weight;//体重（float型）
@property(nonatomic,strong)NSString *AgeStage;//年龄阶段 1：六岁以下 ；2：小学；3：初中；4：高中；5：大学 ；6：从业人员；7：明星
@property(nonatomic,strong)NSString *PerType;//艺人类别 （string 型）
@property(nonatomic,strong)NSString *IsRecommend;//艺人类别 （string 型）
@property(nonatomic,strong)NSString *DisplayOrder;//艺人类别 （string 型）


@property(nonatomic,strong)NSString *IsIDCard;//身份证号（string 型）
@property(nonatomic,strong)NSString *Age;//年龄（int型）
@property(nonatomic,strong)NSString *WorkAdd;//所在学校（所在单位）（string 型）
@property(nonatomic,strong)NSString *ParentName;//家长姓名（string 型）
@property(nonatomic,strong)NSString *ParentTel;//家长电话（string 型）
@property(nonatomic,strong)NSString *Mobile;//手机（string 型）
@property(nonatomic,strong)NSString *Tel;//固话（string 型）
@property(nonatomic,strong)NSString *UserQQ;//（string 型）
@property(nonatomic,strong)NSString *WeChat;//微信（string 型）
@property(nonatomic,strong)NSString *Zip;//邮编（string 型）
@property(nonatomic,strong)NSString *Address;//地址（string 型）
@property(nonatomic,strong)NSString *PerState;//类型（int型）1：普通艺人；3：入库艺人
@property(nonatomic,strong)NSString *ArtSpeList;//艺术特长（string 型）
@property(nonatomic,strong)NSString *EduEducationList;//教育经历（string 型）
@property(nonatomic,strong)NSString *CertificateList;//证书（string 型）
@property(nonatomic,strong)NSString *AchievementList;//艺术成就（string 型）
@property(nonatomic,strong)NSString *EitTime;//修改时间（string 型）
@property(nonatomic,strong)NSString *AddTime;//注册时间（string 型）
@property(nonatomic,strong)NSString *RecPerson;//推荐人（string 型）
@property(nonatomic,strong)NSString *Nationality;//国籍（string 型）
@property(nonatomic,strong)NSString *Nation;//汉（string 型）
@property(nonatomic,strong)NSString *Province;//省（string 型）
@property(nonatomic,strong)NSString *City;//市（string 型）
@property(nonatomic,strong)NSArray *ArtSpe_List;//艺术特长
@property(nonatomic,strong)NSArray *EduEducation_List;//教育经历
@property(nonatomic,strong)NSArray *Certificate_List;//证书
@property(nonatomic,strong)NSArray *Achievement_List;//艺术成就


+(instancetype)init:(NSDictionary *)dic;
- (instancetype)initWithDic:(NSDictionary *)dic;

@end
