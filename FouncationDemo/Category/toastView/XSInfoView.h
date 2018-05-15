/*!
 *  @header XSInfoView.m
 *           CCTVNplan
 *
 *  @brief  央视N计划
 *
 *  @author 王强
 *  @copyright    Copyright © 2016年 Ruby. All rights reserved.
 *  @version    16/5/26.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XSInfoViewLayoutStyle) {
    XSInfoViewLayoutStyleVertical = 0,
    XSInfoViewLayoutStyleHorizontal
};

@interface XSInfoViewStyle : NSObject

@property (strong, nonatomic) UIColor *backgroundColor;

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGSize imageSize;

@property (strong, nonatomic) NSString *info;
@property (assign, nonatomic) CGFloat fontSize;
@property (strong, nonatomic) UIColor *textColor
;
@property (assign, nonatomic) CGFloat maxLabelWidth;

@property (assign, nonatomic) NSInteger durationSeconds;
@property (assign, nonatomic) XSInfoViewLayoutStyle layoutStyle;

@end

@interface XSInfoView : UIView

@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) UIImageView *infoImageView;

+ (void)showInfo:(NSString *)info onView:(UIView *)superView;
+ (void)showInfoWithStyle:(XSInfoViewStyle *)style onView:(UIView *)superView;
- (void)addCenterCons;
@end
