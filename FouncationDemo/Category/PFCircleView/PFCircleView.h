//
//  PFCircleView.h
//  ImageTransform
//
//  Created by Ponfey on 16/9/10.
//  Copyright © 2016年 thirdnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollModel.h"

@class PFCircleView;

@protocol PFCircleViewDelegate <NSObject>

@optional
- (void)circleView:(PFCircleView *)circleView clickedCellWithInfo:(ScrollModel *)info;
- (void)circleView:(PFCircleView *)circleView clickedHeaderWithInfo:(ScrollModel *)info;

@end

@interface PFCircleView : UIView

@property (nonatomic, weak) id<PFCircleViewDelegate> delegate;

@property (nonatomic, strong) NSArray *sourceArray;

@end
