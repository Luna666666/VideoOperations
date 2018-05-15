//
//  PFTextTableViewCell.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/23.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFTextTableViewCell.h"

@interface PFTextTableViewCell ()<UITextFieldDelegate>

@end

@implementation PFTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    textField.text = [expression stringByReplacingMatchesInString:textField.text options:0 range:NSMakeRange(0, textField.text.length) withTemplate:@""];
    if (self.endEditingBlock) {
        self.endEditingBlock(textField.text);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_isPrice) {
        if (textField.text.length == 0 && [string isEqualToString:@"."]) {
            return NO;
        }
        if ([textField.text rangeOfString:@"."].length > 0 && [string isEqualToString:@"."]) {
            return NO;
        }
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([text isEqualToString:@"￥"]) {
            [textField setText:@""];
            return YES;
        }
        NSString *realPrice = [text stringByReplacingOccurrencesOfString:@"￥" withString:@""];
        if ([realPrice floatValue] < 1.f || [realPrice floatValue] > 200.f) {
            return NO;
        }
        if (textField.text.length == 0 && string.length > 0) {
            [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"￥%@", string]]];
            return NO;
        }
        if ([text rangeOfString:@"￥"].length == 0 && text.length != 0) {
            return NO;
        }
        //应测试要求限制用户输入小数点两位，如果有影响到视频上传功能的，请自行修改，本地测试了下，应该不影响
        NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
        [futureString  insertString:string atIndex:range.location];
        
        NSInteger flag=0;
        const NSInteger limited = 2;
        for (int i = futureString.length-1; i>=0; i--) {
            
            if ([futureString characterAtIndex:i] == '.') {
                
                if (flag > limited) {
                    return NO;
                }
                
                break;
            }
            flag++;
        }

    }
    return YES;
//    __block BOOL returnValue = NO;
//    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
//                               options:NSStringEnumerationByComposedCharacterSequences
//                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//                                const unichar hs = [substring characterAtIndex:0];
//                                NSLog(@"---  %@", [[NSString alloc] initWithFormat:@"%1x",hs]);
//                                if (0xd800 <= hs && hs <= 0xdbff) {
//                                    if (substring.length > 1) {
//                                        const unichar ls = [substring characterAtIndex:1];
//                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
//                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
//                                            returnValue = YES;
//                                        }
//                                    }
//                                } else if (substring.length > 1) {
//                                    const unichar ls = [substring characterAtIndex:1];
//                                    if (ls == 0x20e3) {
//                                        returnValue = YES;
//                                    }
//                                } else {
//                                    if (0x2100 <= hs && hs <= 0x278A) {
//                                        returnValue = YES;
//                                    }else if (0x2793 <= hs && hs <= 0x27ff) {
//                                        returnValue = YES;
//                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
//                                        returnValue = YES;
//                                    } else if (0x2934 <= hs && hs <= 0x2935) {
//                                        returnValue = YES;
//                                    } else if (0x3297 <= hs && hs <= 0x3299) {
//                                        returnValue = YES;
//                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
//                                        returnValue = YES;
//                                    }
//                                }
//                            }];
//    if (returnValue) {
//        return NO;
//    }
}

@end
