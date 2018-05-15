//
//  CoverTableViewCell.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 16/9/23.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFCoverTableViewCell.h"

@interface PFCoverTableViewCell ()<UITextViewDelegate>

@end

@implementation PFCoverTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 320 * 0.7);
    [self.bgImageView addSubview:effectView];
    
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.frame = CGRectMake(6, 4, 200, 24);
    self.placeholderLabel.text = @"点击添加描述";
    self.placeholderLabel.alpha = 0.3;
    self.placeholderLabel.font = [UIFont systemFontOfSize:14];
    [self.textView addSubview:_placeholderLabel];
    
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.frame = CGRectMake(SCREEN_WIDTH - 30 - 7, 320 - 25, 30, 24);
    self.countLabel.text = @"100";
    self.countLabel.alpha = 0.3;
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_countLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCover)];
    [self.coverImageView addGestureRecognizer:tap];
    
    self.textView.contentInset = UIEdgeInsetsMake(-2, 0, -7, 0);
    self.textView.delegate = self;
}

- (void)selectCover {
    if (self.setCoverBlock) {
        self.setCoverBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && position) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        if (startOffset < 100) {
            return YES;
        } else {
            return NO;
        }
    }
    NSInteger length = [textView.text stringByReplacingCharactersInRange:range withString:text].length;
    if (length <= 100) {
        return YES;
    }
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        self.placeholderLabel.hidden = NO;
        self.countLabel.text = @"100";
    }
    else{
        self.placeholderLabel.hidden = YES;
        
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (range && position) {
            return;
        }
        
        NSInteger length = textView.text.length;
        if (length <= 100) {
            self.countLabel.text = [NSString stringWithFormat:@"%ld", 100 - length];
        } else {
            self.countLabel.text = @"0";
            NSString *lastChar = [textView.text substringWithRange:NSMakeRange(99, 2)];
            if ([lastChar canBeConvertedToEncoding:NSASCIIStringEncoding]) {
                textView.text = [textView.text substringToIndex:100];
            } else {
                __block NSString *preStr = [textView.text substringToIndex:99];
                __block typeof(textView) textView_b = textView;
                [lastChar enumerateSubstringsInRange:NSMakeRange(0, 2)
                                             options:NSStringEnumerationByComposedCharacterSequences
                                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                              textView_b.text = [preStr stringByAppendingString:substring];
                                              *stop = YES;
                                          }];
            }
        }
    }
    if (self.textChangedBlock) {
        self.textChangedBlock(textView.text);
    }
}

@end
