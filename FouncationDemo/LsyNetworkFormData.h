//
//  LsyNetworkFormData.h
//  NetworkManager
//  Created by swkj_lsy on 16/5/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LsyNetworkFormData : NSObject

/**
 *  data
 */
@property(nonatomic,copy) NSData * data;

/**
 *  名字
 */
@property(nonatomic,copy)NSString * name;

/**
 *  文件名
 */
@property(nonatomic,copy)NSString * fileName;

/**
 *  文件类型
 */
@property(nonatomic,copy)NSString * mimeType;
/**
 *  快速创建
 */
+ (nonnull LsyNetworkFormData *)formDataWithData:(nonnull NSData *)data name:(nonnull NSString *)name fileName:(nonnull NSString *)fileName mimeType:(nonnull NSString *)mimeType;

+ (nonnull LsyNetworkFormData *)formDataWithImg:(nonnull UIImage *)image name:(nonnull NSString *)name fileName:(nonnull NSString *)fileName scale:(CGFloat)scale;
@end
