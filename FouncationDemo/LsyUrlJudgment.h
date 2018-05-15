//
//  LsyUrlJudgment.h
//  NetworkManager
//
//  Created by swkj_lsy on 16/5/30.
//  Copyright © 2016年 wzx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LsyUrlJudgment : NSObject
+(BOOL)initWithRespon:(NSError *)error;//重新登录
+(BOOL)showLineFailde:(NSError *)error;//不能连接服务器
+(BOOL)showLineOutTime:(NSError *)error;//连接超时
@end
