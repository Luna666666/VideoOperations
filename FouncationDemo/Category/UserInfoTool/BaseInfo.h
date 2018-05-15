//
//  BaseInfo.h
//  Nplan
//
//  Created by swkj_lsy on 16/6/25.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseInfo : NSObject
@property(nonatomic,strong)NSNumber *UId;//登录用户id，（int型）
@property(nonatomic,strong)NSNumber *PNo;//艺人编号（string 型）
@property(nonatomic,copy) NSDictionary * token;//登录的请求头
@property(nonatomic,strong)NSString *PerImg;//头像
@property(nonatomic,strong)NSString *PerName;//艺人姓名（string 型）
@end
