//
//  MICSecurity.m
//  MadeInChina
//
//  Created by swkj001152 on 14-7-4.
//  Copyright (c) 2014年 wgf. All rights reserved.
//

#import "MICSecurity.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation MICSecurity

//DES加密
+(NSString *)encryptWithDES:(NSString *)plainText Key:(NSString *)strKey Iv:(NSString*)strIv
{
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    const char* iv=[strIv UTF8String];
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [strKey UTF8String], kCCKeySizeDES,
                                          iv,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [data base64Encoding];
//               NSLog(@"aaaaaaaaaa加密： %@",ciphertext);
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
//                ciphertext=[ciphertext stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
                //ciphertext = [DESEncry URLEscaped:ciphertext];
    }
    return ciphertext;
}

@end
