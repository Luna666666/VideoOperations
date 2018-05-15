//
//  MobileNum.h
//  Nplan
//
//  Created by swkj_lsy on 16/7/19.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileNum : NSObject
+ (BOOL) isMobile:(NSString *)mobileNum;
+ (BOOL) isAge:(NSString *)age;
@end
