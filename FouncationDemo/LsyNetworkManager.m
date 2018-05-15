//
//  LsyNetworkManager.m
//  NetworkManager
//  Created by swkj_lsy on 16/5/30.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "LsyNetworkManager.h"
 
@interface LsyNetworkManager()
@property (nonatomic,copy)NSString * url;
@property (nonatomic,assign)RequestType wRequestType;
@property (nonatomic,assign)RequestSerializer requestSerialize;
@property (nonatomic,assign)ResponseSerializer responseSerialize;
@property (nonatomic,copy)id parameters;
@property (nonatomic,copy)NSDictionary * wHTTPHeader;
@property (nonatomic,assign)ApiVersion version;
@property (nonatomic,strong)LsyNetworkFormData * formData;
@end
@implementation LsyNetworkManager

+ (LsyNetworkManager *)manager {
    
    static LsyNetworkManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LsyNetworkManager alloc]init];
        [manager replace];
    });
    return manager;
}

- (LsyNetworkManager *(^)(NSString *))setRequest {
    return ^LsyNetworkManager* (NSString * url) {
        self.url = url;
        return self;
    };
}

- (LsyNetworkManager *(^)(RequestType))RequestType {
    return ^LsyNetworkManager* (RequestType type) {
        self.wRequestType = type;
        return self;
    };
}

- (LsyNetworkManager* (^)(id parameters))Parameters {
    return ^LsyNetworkManager* (id parameters) {
        self.parameters = parameters;
        return self;
    };
}
- (LsyNetworkManager *(^)(NSDictionary *))HTTPHeader {
    return ^LsyNetworkManager* (NSDictionary * HTTPHeaderDic) {
        self.wHTTPHeader = HTTPHeaderDic;
        return self;
    };
}

- (LsyNetworkManager *(^)(RequestSerializer))RequestSerialize {
    return ^LsyNetworkManager* (RequestSerializer requestSerializer) {
        self.requestSerialize = requestSerializer;
        return self;
    };
}

- (LsyNetworkManager *(^)(ApiVersion))Version {
    return ^LsyNetworkManager * (ApiVersion version) {
        self.version = version;
        return self;
    };
}

- (LsyNetworkManager *(^)(ResponseSerializer))ResponseSerialize {
    return ^LsyNetworkManager* (ResponseSerializer responseSerializer) {
        self.responseSerialize = responseSerializer;
        return self;
    };
}

- (LsyNetworkManager *(^)(LsyNetworkFormData *))FormData {
    return ^ LsyNetworkManager * (LsyNetworkFormData * formData){
        self.formData = formData;
        return self;
    };
}

- (LsyNetworkManager *)setUpBeforeStart {
    LsyNetworkManager * manager = [[self class]manager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 15.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    //设置请求头
    [self setupRequestSerializerWithManager:manager];
    [self setupHTTPHeaderWithManager:manager];
    //设置返回头
    [self setupResponseSerializerWithManager:manager];
    return manager;
}

- (void)startRequestWithSuccess:(void (^)(id))success failure:(void (^)(NSError * error))failure {
    [self startRequestWithProgress:nil success:success failure:failure];
}

- (void)startRequestWithProgress:(void (^)(NSProgress *))progress success:(void (^)(id))success failure:(void (^)(NSError * error))failure {
    
    LsyNetworkManager * manager = [self setUpBeforeStart];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 12.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSString * url = [self setupUrl];
    switch (self.wRequestType) {
        case GET: {
            [manager GET:url parameters:self.parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 failure(error);
            }];
        }
            break;
            
        case POST: {
            if (self.formData) {
                [manager POST:url parameters:self.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    [formData appendPartWithFileData:self.formData.data name:self.formData.name fileName:self.formData.fileName mimeType:self.formData.mimeType];
                } progress:^(NSProgress * _Nonnull uploadProgress) {
//                     progress(uploadProgress);
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     success(responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     failure(error);
                }];
                
            } else {
                [manager POST:url parameters:self.parameters progress:^(NSProgress * _Nonnull uploadProgress) {
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    success(responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failure(error);
                }];
            }
        }
            break;
            
        case PUT: {
            [manager PUT:url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                failure(error);
            }];
        }
            break;
            
        case PATCH: {
            [manager PATCH:url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                failure(error);
            }];
        }
            break;
            
        case DELETE: {
            [manager DELETE:url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                failure(error);
            }];
        }
            break;
            
        default:
            break;
    }
    [self replace];
}

- (LsyNetworkManager *)setupRequestSerializerWithManager:(LsyNetworkManager *)manager {
    
    switch (self.requestSerialize) {
        case RequestSerializerJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            manager.requestSerializer.timeoutInterval = 12.f;
            [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        }
            break;
        case RequestSerializerHTTP: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            manager.requestSerializer.timeoutInterval = 12.f;
            [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        }
            break;
        default:
            break;
    }
    return manager;
}

- (LsyNetworkManager *)setupResponseSerializerWithManager:(LsyNetworkManager *)manager {
    switch (self.responseSerialize) {
           
        case ResponseSerializerJSON: {
//            [AFJSONResponseSerializer serializer].removesKeysWithNullValues = YES;
//            AFJSONResponseSerializer * response = [[AFJSONResponseSerializer alloc]init];
//            response.removesKeysWithNullValues = YES;
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
//            manager.responseSerializer = response;
           
            
        }
            break;
        case ResponseSerializerHTTP: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        }
            break;
        default:
            break;
    }
    return manager;
}

- (LsyNetworkManager *)setupHTTPHeaderWithManager:(LsyNetworkManager *)manager {
    for (NSString * key in self.wHTTPHeader.allKeys) {
        [manager.requestSerializer setValue:self.wHTTPHeader[key] forHTTPHeaderField:key];
    }
    return manager;
}

- (NSString *)setupUrl {
    NSString * version = @"";
    switch (self.version) {
        case V1: {
            version = @"v1";
        }
            break;
        case V2: {
            version = @"v2";
        }
            break;
        case NONE: {
            return self.url;
        }
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@,%@",self.url,version];
}

//重置
- (void)replace {
    self.url = nil;
    self.version = NONE;
    self.wRequestType = GET;
    self.parameters = nil;
    self.wHTTPHeader = nil;
    self.requestSerialize = RequestSerializerHTTP;
    self.responseSerialize = ResponseSerializerJSON;
    self.formData = nil;
}
@end
