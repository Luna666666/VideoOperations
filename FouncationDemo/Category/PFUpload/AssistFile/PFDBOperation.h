//
//  PFDBOperation.h
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/10/9.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFUploadModel.h"

@interface PFDBOperation : NSObject

+ (instancetype)sharedInstance;

- (void)addNewUploadInfo:(PFUploadModel *)info;
- (void)deleteUploadInfo:(PFUploadModel *)info;
- (NSArray *)queryAllUploadInfo;
- (void)deleteAllUploadInfo;
- (NSInteger)queryRecordCounts;

@end
