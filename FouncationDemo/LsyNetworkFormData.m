//
//  LsyNetworkFormData.m
//  NetworkManager
//  Created by swkj_lsy on 16/5/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//
#import "LsyNetworkFormData.h"

@implementation LsyNetworkFormData

+ (LsyNetworkFormData *)formDataWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    LsyNetworkFormData * dataObj = [[LsyNetworkFormData alloc]init];
    dataObj.data = data;
    dataObj.name = name;
    dataObj.fileName = fileName;
    dataObj.mimeType = mimeType;
    return dataObj;
}

+ (LsyNetworkFormData *)formDataWithImg:(UIImage *)image name:(NSString *)name fileName:(NSString *)fileName scale:(CGFloat)scale {
    LsyNetworkFormData * dataObj = [[LsyNetworkFormData alloc]init];
    if (UIImagePNGRepresentation(image) == nil) {
        dataObj.data = UIImageJPEGRepresentation(image, scale);
        dataObj.mimeType = @"JPEG";
    }else {
        dataObj.data = UIImagePNGRepresentation(image);
        dataObj.mimeType = @"PNG";
    }
    dataObj.name = name;
    dataObj.fileName = fileName;
    return dataObj;
}
@end
