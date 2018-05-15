//
//  LsyNetworkManager.h
//  NetworkManager
//  Created by swkj_lsy on 16/5/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "LsyNetworkFormData.h"
@interface LsyNetworkManager : AFHTTPSessionManager
typedef NS_ENUM(NSInteger,RequestType){
    GET,
    POST,
    PUT,
    DELETE,
    PATCH,
};

typedef NS_ENUM(NSInteger,RequestSerializer){
    RequestSerializerJSON,
    RequestSerializerHTTP
};

typedef NS_ENUM(NSInteger,ResponseSerializer){
    ResponseSerializerJSON,
    ResponseSerializerHTTP
};

typedef NS_ENUM(NSInteger,ApiVersion){
    NONE,
    V1,
    V2
};

+ (LsyNetworkManager *)manager;

/** 
 *  @method      填充网址
 */
- (LsyNetworkManager* (^)(NSString * url))setRequest;

/**
 *  @method      填充请求类型，默认为GET
 */
- (LsyNetworkManager* (^)(RequestType type))RequestType;

/**
 *  @method      填充参数
 */
- (LsyNetworkManager* (^)(id parameters))Parameters;

/**
 *  @method      填充请求头
 */
- (LsyNetworkManager* (^)(NSDictionary * HTTPHeaderDic))HTTPHeader;

/**
 *  @method      更改数据发送类型，默认HTTP
 */
- (LsyNetworkManager* (^)(RequestSerializer))RequestSerialize;

/**
 *  @method      formData
 */
- (LsyNetworkManager*(^)(LsyNetworkFormData * formData))FormData;

/**
 *  @method      更改数据接收类型，默认JSON
 */
- (LsyNetworkManager* (^)(ResponseSerializer))ResponseSerialize;

/**
 *  版本
 */
- (LsyNetworkManager* (^)(ApiVersion))Version;

/**
 *  发送请求(带进度)，仅限POST、GET
 *
 *  @param progress 下载或上传进度的回调
 *  @param success  成功的回调
 *  @param failure  失败的回调
 */
- (void)startRequestWithProgress:(void(^)(NSProgress * progress))progress success:(void(^)(id response))success failure:(void (^)(NSError * error))failure;

/**
 *  发送请求(不带进度)
 *
 *  @param success 成功的回调
 *  @param failure 失败的回调
 */
- (void)startRequestWithSuccess:(void(^)(id response))success failure:(void (^)(NSError * error))failure;
@end
