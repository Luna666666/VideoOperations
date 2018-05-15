//
//  PFNumberTableViewCell.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/23.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFNumberTableViewCell.h"

@interface PFNumberTableViewCell ()<UITextFieldDelegate>

@end

@implementation PFNumberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!_percent.hidden) {
        if (textField.text.length == 0 && [string isEqualToString:@"."]) {
            return NO;
        }
        if ([textField.text rangeOfString:@"."].length > 0 && [string isEqualToString:@"."]) {
            return NO;
        }
        NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
        [futureString  insertString:string atIndex:range.location];
        
        if ([futureString floatValue] > 94) {
            return NO;
        }
        
        //应测试要求限制用户输入小数点两位，如果有影响到视频上传功能的，请自行修改
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
        
    } else {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([text integerValue] > 2000000000) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.endEditingBlock) {
        self.endEditingBlock(textField.text);
    }
}

@end
