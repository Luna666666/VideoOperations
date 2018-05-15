//
//  MICSecurity.h
//  MadeInChina
//
//  Created by swkj001152 on 14-7-4.
//  Copyright (c) 2014年 wgf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MICSecurity : NSObject

/**
 *  DES加密
 */
+(NSString *)encryptWithDES:(NSString *)plainText Key:(NSString *)strKey Iv:(NSString*)strIv;

@end
