////
////  EarningCellTableViewCell.m
////  CCTVVideo
////
////  Created by swkj on 16/9/21.
////  Copyright © 2016年 dnq. All rights reserved.
////
//
//#import "UserTableViewCell.h"
//#import "UIImageView+WebCache.h"
//#import "CCTVVideo.pch"
//#import "Constants.h"
//@implementation UserTableViewCell
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        self.selectionStyle=UITableViewCellSelectionStyleNone;
//        
//        quShi=[[UIImageView alloc]initWithFrame:CGRectMake(Margin1/2*ScreenWidth/375,Margin1*ScreenWidth/375,Margin1*ScreenWidth/375,self.frame.size.height)];
//        quShi.tag=998;
//        quShi.contentMode=UIViewContentModeScaleAspectFit;
//        [self addSubview:quShi];
//
//        huanGuan=[[UIImageView alloc]initWithFrame:CGRectMake(Margin1*3*ScreenWidth/375,Margin1*1.2*ScreenWidth/375,3*Margin1*ScreenWidth/375,self.frame.size.height)];
//        huanGuan.tag=999;
//        huanGuan.contentMode=UIViewContentModeScaleAspectFit;
//        [self addSubview:huanGuan];
//        
//        headIcon=[[UIImageView alloc]initWithFrame:CGRectMake(huanGuan.frame.origin.x+huanGuan.frame.size.width+Margin1*ScreenWidth/375,Margin1*ScreenWidth/375,CellWH*ScreenWidth/375, CellWH*ScreenWidth/375)];
//        headIcon.backgroundColor=[UIColor whiteColor];
//        headIcon.layer.masksToBounds=YES;
//        headIcon.layer.cornerRadius=headIcon.frame.size.height/2;;
//        headIcon.layer.borderWidth=0.5;
//        headIcon.layer.borderColor=[UIColor colorWithRed:0.941 green:0.969 blue:0.992 alpha:1.00].CGColor;
//        headIcon.contentMode= UIViewContentModeScaleToFill;
//        [self addSubview:headIcon];
//        
//        smallIcon=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(headIcon.frame)-Margin1*ScreenWidth/375,CGRectGetMaxY(headIcon.frame)-15,20*ScreenWidth/375,20*ScreenWidth/375)];
//        smallIcon.contentMode= UIViewContentModeScaleAspectFit;
//        [self addSubview:smallIcon];
//        
//
//          nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(headIcon.frame.origin.x+headIcon.frame.size.width+1.5*Margin1*ScreenWidth/375,headIcon.frame.origin.y+Margin1*ScreenWidth/375,150*ScreenWidth/375,headIcon.frame.size.height/2)];
//     
//        nameLabel.textAlignment=NSTextAlignmentLeft;
////        nameLabel.textColor=[UIColor colorWithRed:0.396 green:0.396 blue:0.396 alpha:1.00];
//        nameLabel.font=[UIFont systemFontOfSize:16*FONTSCALE_WIDTH];
//        [self addSubview:nameLabel];
//       
//        
//        Popularity=[[UILabel alloc]initWithFrame                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          :CGRectMake(ScreenWidth-135*ScreenWidth/375,nameLabel.frame.origin.y,100*ScreenWidth/375,headIcon.frame.size.height/2)];
//        Popularity.textAlignment=NSTextAlignmentRight;
//        Popularity.textColor=[UIColor colorWithRed:0.333 green:0.333 blue:0.333 alpha:1.00];
//        Popularity.font=[UIFont boldSystemFontOfSize:14*FONTSCALE_WIDTH];
//        [self addSubview:Popularity];
//        
//        bellIcon=[[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth-30*ScreenWidth/375,Popularity.frame.origin.y,20*ScreenWidth/375,20*ScreenWidth/375)];
//        bellIcon.contentMode= UIViewContentModeScaleAspectFit;
//        [self addSubview:bellIcon];
//        
//    }
//    return self;
//
//}
//-(void)setUserRankData:(EUserRank*)userRank showNum:(NSInteger)num{
//    [headIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",userRank.PerImg]] placeholderImage:[UIImage imageNamed:@"用户排名头像"] options:SDWebImageRetryFailed];
//    if ([userRank.PerType isEqualToString:@"1"]) {
//        smallIcon.hidden = YES;
//    }else if ([userRank.PerType isEqualToString:@"2"]){
//        smallIcon.hidden = NO;
//        smallIcon.image=[UIImage imageNamed:@"制作联盟"];
//        
//    }else if ([userRank.PerType isEqualToString:@"3"]){
//        smallIcon.hidden = NO;
//        smallIcon.image=[UIImage imageNamed:@"自媒体"];
//    }
//    nameLabel.text=userRank.PetName;
//    Popularity.text=[NSString stringWithFormat:@"%@",userRank.Profit];
//    bellIcon.image=[UIImage imageNamed:@"钱袋"];
//}
//
//
//
//@end
