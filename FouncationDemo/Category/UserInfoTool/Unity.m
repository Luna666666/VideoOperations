

#import "Unity.h"
//#import "pinyin.h"
#define MainScreen_Width  [UIScreen mainScreen].bounds.size.width

@implementation Unity

+(NSString *)ToString:(id)object{
    if (!object)
        return @"";
    if ([object isKindOfClass:[NSNull class]])
        return @"";
    return [NSString stringWithFormat:@"%@",object];
}
+(NSArray *)ToArray:(id)object{
    if (!object)
        return @[@""];
    if ([object isKindOfClass:[NSNull class]])
        return @[@""];
    return [NSArray arrayWithObject:object];
}
+(NSNumber *)ToNumber:(id)object{
    return [NSNumber numberWithLongLong:[[Unity ToString:object] longLongValue]];
}

+(NSNumber *)ToFoloatNum:(id)object{
    return [NSNumber numberWithFloat:[[Unity ToString:object] floatValue]];
}
+(BOOL)isNilOrNullOrEmptyOrWhitespace:(NSString*)aStr{
    return [aStr isKindOfClass:[NSNull class]] || aStr == nil || 0 == aStr.length || ![aStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}


@end


@implementation NSString (Lord)

-(NSString *)Trim{
    NSString *temp=[Unity ToString:self];
    return [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(NSString *)dateByAddingTimeInterval:(float)timeInterval{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    format.dateFormat=@"yyyy-MM-dd HH:mm:ss.SSS";
    format.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *date=[[format dateFromString:[self Trim]] dateByAddingTimeInterval:timeInterval];
    return [format stringFromDate:date];
}

-(NSString *)DateWithFormat:(NSString *)format{
    NSDate *date=[NSDateFormatter dateFromString:self];
    return [Unity ToString:[NSDateFormatter stringFromDate:date format:format]];
}

@end

@implementation NSDateFormatter (Lord)
+ (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    format.dateFormat=@"yyyy-MM-dd HH:mm:ss.SSS";
    return [format stringFromDate:date];
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)formatStr{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    format.dateFormat=formatStr;
    format.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    return [format stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string{
    return [NSDateFormatter dateFromString:string format:@"yyyy-MM-dd HH:mm:ss.SSS"];
}

+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)formatStr{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    format.dateFormat=formatStr;
    format.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    return [format dateFromString:string];
}
@end
