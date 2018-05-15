//
//  LsyRmoveVideo.m
//  ManufacturingAlliance
//
//  Created by swkj_lsy on 16/10/17.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "LsyRmoveVideo.h"

@implementation LsyRmoveVideo
+(void)LsyRmoveVideo:(NSURL *)url{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSRange range = [[url absoluteString] rangeOfString:@"tmp"];
    NSString *realUrlStr = [[url absoluteString] substringFromIndex:range.location];
    NSString *urlStr = [NSHomeDirectory() stringByAppendingFormat:@"/%@", realUrlStr];
    if ([manager fileExistsAtPath:urlStr]) {
        [manager removeItemAtPath:urlStr error:nil];
    }
}
@end
