//
//  PFDBOperation.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/10/9.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFDBOperation.h"
#import "FMDB.h"
#import "SDImageCache.h"
#import "MainUserInfo.h"

static FMDatabaseQueue *DBQueue;

@implementation PFDBOperation

+ (instancetype)sharedInstance{
    static PFDBOperation *operation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operation = [[PFDBOperation alloc] init];
        DBQueue = [FMDatabaseQueue databaseQueueWithPath:[operation getDataBasePath]];
        [operation creatTable];
    });
    return operation;
}

- (void)creatTable {
    NSString *sqlCommond = @"create table if not exists UploadInfoTable (videoDate text, videoUrl text, videoDescription text, videoName text, videoType integer, videoTypeStr text,  videoSubType integer, videoSubTypeStr text, videoDirection text, videoWriter text, videoActor text, videoPrice text, spreadCycle integer, spreadCycleStr text, video1SpreadTimes text, video1SpreadRewards text, video2SpreadTimes text, video2SpreadRewards text, video3SpreadTimes text, video3SpreadRewards text, userId text)";
    [DBQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sqlCommond];
    }];
}

- (NSString *)getDataBasePath{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentsDirectory stringByAppendingPathComponent:@"Database.db"];
}

- (void)addNewUploadInfo:(PFUploadModel *)info {
    NSString *sqlCommond = @"insert into UploadInfoTable (videoDate, videoUrl, videoDescription, videoName, videoType, videoTypeStr, videoSubType, videoSubTypeStr, videoDirection, videoWriter, videoActor, videoPrice, spreadCycle, spreadCycleStr, video1SpreadTimes, video1SpreadRewards, video2SpreadTimes, video2SpreadRewards, video3SpreadTimes, video3SpreadRewards, userId) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    [DBQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        NSRange range = [[info.videoUrl absoluteString] rangeOfString:@"tmp"];
        NSString *realUrlStr = [[info.videoUrl absoluteString] substringFromIndex:range.location];
        [db executeUpdate:sqlCommond, info.videoDate, realUrlStr, info.videoDescription, info.videoName, [NSNumber numberWithInteger:info.videoType], info.videoTypeStr, [NSNumber numberWithInteger:info.videoSubType], info.videoSubTypeStr, info.videoDirection, info.videoWriter, info.videoActor, info.videoPrice, [NSNumber numberWithInteger:info.spreadCycle], info.spreadCycleStr, info.video1SpreadTimes, info.video1SpreadRewards, info.video2SpreadTimes, info.video2SpreadRewards, info.video3SpreadTimes, info.video3SpreadRewards, [APPInfo shareInfo].cuId];
        [db commit];
    }];
}

- (void)deleteUploadInfo:(PFUploadModel *)info {
    NSString *sqlCommond = @"delete from UploadInfoTable where videoUrl = ?";
    [DBQueue inDatabase:^(FMDatabase *db) {
        NSRange range = [[info.videoUrl absoluteString] rangeOfString:@"tmp"];
        NSString *realUrlStr = [[info.videoUrl absoluteString] substringFromIndex:range.location];
        [db beginTransaction];
        [db executeUpdate:sqlCommond, realUrlStr];
        [db commit];
    }];
}

- (void)deleteAllUploadInfo {
    NSString *sqlCommond = @"delete from UploadInfoTable where userId = ?";
    [DBQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        [db executeUpdate:sqlCommond, [APPInfo shareInfo].cuId];
        [db commit];
    }];
}

- (NSArray *)queryAllUploadInfo {
    NSString *sqlCommond = @"select * from UploadInfoTable where userId = ?";
    __block NSMutableArray *array = [NSMutableArray array];
    __weak typeof(self) weak_self = self;
    [DBQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlCommond, [APPInfo shareInfo].cuId];
        while ([result next]) {
            PFUploadModel *model = [weak_self modelFormResult:result];
            [array addObject:model];
        }
        [result close];
    }];
    return array;
}

- (NSInteger)queryRecordCounts {
    NSString *sqlCommond = @"select count(*) from UploadInfoTable where userId = ?";
    __block NSInteger count = 0;
    [DBQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlCommond, [APPInfo shareInfo].cuId];
        while ([result next]) {
            count = [result intForColumnIndex:0];
        }
    }];
    return count;
}

- (PFUploadModel *)modelFormResult:(FMResultSet *)result {
    PFUploadModel *model = [[PFUploadModel alloc] init];
    NSString *urlStr = [NSString stringWithFormat:@"file:///private%@", [NSHomeDirectory() stringByAppendingFormat:@"/%@", [result stringForColumn:@"videoUrl"]]];
    model.videoUrl = [NSURL URLWithString:urlStr];
    model.videoDescription = [result stringForColumn:@"videoDescription"];
    model.videoName = [result stringForColumn:@"videoName"];
    model.videoType = [result intForColumn:@"videoType"];
    model.videoTypeStr = [result stringForColumn:@"videoTypeStr"];
    model.videoSubType = [result intForColumn:@"videoSubType"];
    model.videoSubTypeStr = [result stringForColumn:@"videoSubTypeStr"];
    model.videoDirection = [result stringForColumn:@"videoDirection"];
    model.videoWriter = [result stringForColumn:@"videoWriter"];
    model.videoActor = [result stringForColumn:@"videoActor"];
    model.videoPrice = [result stringForColumn:@"videoPrice"];
    model.spreadCycle = [result intForColumn:@"spreadCycle"];
    model.spreadCycleStr = [result stringForColumn:@"spreadCycleStr"];
    model.video1SpreadTimes = [result stringForColumn:@"video1SpreadTimes"];
    model.video1SpreadRewards = [result stringForColumn:@"video1SpreadRewards"];
    model.video2SpreadTimes = [result stringForColumn:@"video2SpreadTimes"];
    model.video2SpreadRewards = [result stringForColumn:@"video2SpreadRewards"];
    model.video3SpreadTimes = [result stringForColumn:@"video3SpreadTimes"];
    model.video3SpreadRewards = [result stringForColumn:@"video3SpreadRewards"];
    model.videoDate = [result stringForColumn:@"videoDate"];
    model.videoCoverImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[result stringForColumn:@"videoUrl"]];
    return model;
}

@end
