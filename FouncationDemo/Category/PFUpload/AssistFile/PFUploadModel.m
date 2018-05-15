//
//  PFUploadModel.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/29.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFUploadModel.h"

@implementation PFUploadModel

- (NSString *)hasEmpty {
    NSString *warningStr = nil;
    if ([self.videoDescription stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        warningStr = @"请输入作品描述";
    } else if ([self.videoName stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        warningStr = @"请输入作品名称";
    } else if (self.videoType == 0) {
        warningStr = @"请选择作品类型";
    } else if (self.videoSubType == 0) {
        warningStr = @"请选择作品小类";
    } else if ([self.videoDirection stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        warningStr = @"请输入导演";
    } else if ([self.videoWriter stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        warningStr = @"请输入编剧";
    } else if ([self.videoActor stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        warningStr = @"请输入演员";
    } else if ([self.videoPrice stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        warningStr = @"请输入作品在线观看价格";
    } else {
        NSArray *defaultArray = @[@"video1SpreadTimes", @"video1SpreadRewards", @"video2SpreadTimes", @"video2SpreadRewards", @"video3SpreadTimes", @"video3SpreadRewards"];
        for (NSString *propertyName in defaultArray) {
            if (![self valueForKey:propertyName]) {
                [self setValue:@"0" forKey:propertyName];
            }
        }
    }
    
    return warningStr;
}

@end
