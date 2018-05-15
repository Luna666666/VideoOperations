//
//  Unity.h
//  DamiOA
//
//  Created by ZhouLord on 15/3/16.
//  Copyright (c) 2015年 ZhouLord. All rights reserved.
//
#import <Foundation/Foundation.h>
//#import "AlertView.h"
#import "UIImageView+WebCache.h"

@interface Unity : NSObject

+(NSString *)ToString:(id)object;
+(NSNumber *)ToNumber:(id)object;
+(NSNumber *)ToFoloatNum:(id)object;
+(NSArray *)ToArray:(id)object;
+(BOOL)isNilOrNullOrEmptyOrWhitespace:(NSString*)aStr;

@end                      

#define ViewBackGround   [UIColor colorWithRed:0.953f green:0.945f blue:0.945f alpha:1.00f]
#define LineColor        [UIColor colorWithRed:0.333 green:0.835 blue:0.443 alpha:1.00] //绿色
#define BlueColor        [UIColor colorWithRed:0.129f green:0.588f blue:0.953f alpha:1.00f] //蔚蓝
#define OrangeColor      [UIColor colorWithRed:0.965f green:0.682f blue:0.537f alpha:1.00f] //橙色
#define YellowColor      [UIColor colorWithRed:0.910f green:0.863f blue:0.455f alpha:1.00f] //黄色
#define CellBackColor    [UIColor colorWithRed:0.949f green:0.937f blue:0.941f alpha:1.00f] //cell背景色

#define TitleFont        [UIFont systemFontOfSize:19]
#define TextFont         [UIFont systemFontOfSize:15]
#define DetailFont       [UIFont systemFontOfSize:13]
#define TipFont          [UIFont systemFontOfSize:11]

#define TextColor        [UIColor colorWithRed:1.000 green:0.494 blue:0.016 alpha:1.00]
#define DetailColor      [UIColor colorWithRed:0.502f green:0.463f blue:0.424f alpha:1.00f]
#define WhiteDetailColor [UIColor colorWithRed:0.867f green:0.867f blue:0.867f alpha:1.00f]

#define BtnSize           26
#define IconSize          18
#define FlagSize          16
#define IconColor        [UIColor colorWithRed:0.400f green:0.400f blue:0.400f alpha:1.00f]



@interface NSString (Lord)
-(NSString *)Trim;
-(NSString *)dateByAddingTimeInterval:(float)timeInterval;
-(NSString *)DateWithFormat:(NSString *)format;
@end

@interface NSDateFormatter (Lord)
+(NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)formatStr;
+(NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)formatStr;
@end

