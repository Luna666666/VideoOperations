//
//  PFCircleView.m
//  ImageTransform
//
//  Created by Ponfey on 16/9/10.
//  Copyright © 2016年 thirdnet. All rights reserved.
//

#import "PFCircleView.h"
#import "PFCollectionViewCell.h"
#import "PFCollectionViewLayout.h"
#import "ManufacturingDetailViewController.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@interface PFCircleView ()<UICollectionViewDelegate, UICollectionViewDataSource, PFCollectionViewCellDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger pageOffset;
@property (nonatomic, assign) CGFloat originalOffset;
@property (nonatomic, assign) NSInteger sourceArrayCount;
@property (nonatomic, assign) NSInteger originalItem;

@end

@implementation PFCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_bgImageView];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualView.frame = _bgImageView.bounds;
        [self.bgImageView addSubview:visualView];
        
        PFCollectionViewLayout *layout = [[PFCollectionViewLayout alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_collectionView];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"PFCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    }
    return self;
}

- (void)setSourceArray:(NSArray *)sourceArray{
    if (sourceArray.count!=0) {
        _sourceArray = sourceArray;
        self.sourceArrayCount = _sourceArray.count;
        [self.collectionView reloadData];
        
        NSInteger index = 100 % _sourceArrayCount;
        NSInteger offset = index < _sourceArrayCount - index ? index : index - _sourceArrayCount;
        self.originalItem = 100 - offset;
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_originalItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.originalOffset = self.collectionView.contentOffset.x;
        
        ScrollModel *model = _sourceArray[_originalItem % _sourceArrayCount];
        [self setBgImageView:_bgImageView withInterceptedImageOfURL:model.imgPath];
    }
   
}

- (void)setBgImageView:(UIImageView *)bgImageView withInterceptedImageOfURL:(NSString *)urlString {
    if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:urlString]) {
        UIImage *originalImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
        
        CGRect interceptRect = CGRectZero;
        if ((originalImage.size.width / originalImage.size.height) <= 4/3.f) {
            CGFloat newHeight = originalImage.size.width * 3/4;
            interceptRect = CGRectMake(0, originalImage.size.height / 2 - newHeight / 2, originalImage.size.width, newHeight);
        } else if (originalImage.size.width / originalImage.size.height > 4/3.f) {
            CGFloat newWidth = originalImage.size.height * 4/3;
            interceptRect = CGRectMake(originalImage.size.width / 2 - newWidth / 2, 0, newWidth, originalImage.size.height);
        }
        CGImageRef cgImgae = originalImage.CGImage;
        CGImageRef targetImage = CGImageCreateWithImageInRect(cgImgae, interceptRect);
        UIImage *tempImage = [UIImage imageWithCGImage:targetImage];
        
        CGFloat bgHeight = tempImage.size.height / 10;
        CGFloat bgWidth = tempImage.size.width / 10;
        CGImageRef targetCGImage = CGImageCreateWithImageInRect(targetImage, CGRectMake(tempImage.size.width / 2 - bgWidth, tempImage.size.height / 2 - bgHeight, bgWidth, bgHeight));
        UIImage *resultImage = [UIImage imageWithCGImage:targetCGImage];
        CGImageRelease(targetCGImage);
        CGImageRelease(targetImage);
        [bgImageView setImage:resultImage];
    } else {
        NSURL *url = [NSURL URLWithString:urlString];
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            UIImage *originalImage = image;
            
            CGRect interceptRect = CGRectZero;
            if ((originalImage.size.width / originalImage.size.height) <= 4/3.f) {
                CGFloat newHeight = originalImage.size.width * 3/4;
                interceptRect = CGRectMake(0, originalImage.size.height / 2 - newHeight / 2, originalImage.size.width, newHeight);
            } else if (originalImage.size.width / originalImage.size.height > 4/3.f) {
                CGFloat newWidth = originalImage.size.height * 3/4;
                interceptRect = CGRectMake(originalImage.size.width / 2 - newWidth / 2, 0, newWidth, originalImage.size.height);
            }
            CGImageRef cgImgae = originalImage.CGImage;
            CGImageRef targetImage = CGImageCreateWithImageInRect(cgImgae, interceptRect);
            UIImage *tempImage = [UIImage imageWithCGImage:targetImage];
            
            CGFloat bgHeight = tempImage.size.height / 10;
            CGFloat bgWidth = tempImage.size.width / 10;
            CGImageRef targetCGImage = CGImageCreateWithImageInRect(targetImage, CGRectMake(tempImage.size.width / 2 - bgWidth, tempImage.size.height / 2 - bgHeight, bgWidth, bgHeight));
            UIImage *resultImage = [UIImage imageWithCGImage:targetCGImage];
            CGImageRelease(targetCGImage);
            CGImageRelease(targetImage);
            [bgImageView setImage:resultImage];
        }];
    }
}

- (void)setImageView:(UIImageView *)imageView withInterceptedImageOfURL:(NSString *)urlString {
    if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:urlString]) {
        UIImage *originalImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
        CGRect interceptRect = CGRectZero;
        if ((originalImage.size.width / originalImage.size.height) <= 4/3.f) {
            CGFloat newHeight = originalImage.size.width * 3/4;
            interceptRect = CGRectMake(0, originalImage.size.height / 2 - newHeight / 2, originalImage.size.width, newHeight);
        } else if (originalImage.size.width / originalImage.size.height > 4/3.f) {
            CGFloat newWidth = originalImage.size.height * 4/3;
            interceptRect = CGRectMake(originalImage.size.width / 2 - newWidth / 2, 0, newWidth, originalImage.size.height);
        }
        CGImageRef cgImgae = originalImage.CGImage;
        CGImageRef targetImage = CGImageCreateWithImageInRect(cgImgae, interceptRect);
        UIImage *resultImage = [UIImage imageWithCGImage:targetImage];
        CGImageRelease(targetImage);
        [imageView setImage:resultImage];
    } else {
        NSURL *url = [NSURL URLWithString:urlString];
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            UIImage *originalImage = image;
            CGRect interceptRect = CGRectZero;
            if (originalImage.size.width / originalImage.size.height <= 4/3.f) {
                CGFloat newHeight = originalImage.size.width * 3/4;
                interceptRect = CGRectMake(0, originalImage.size.height / 2 - newHeight / 2, originalImage.size.width, newHeight);
            } else if (originalImage.size.width / originalImage.size.height > 4/3.f) {
                CGFloat newWidth = originalImage.size.height * 4/3;
                interceptRect = CGRectMake(originalImage.size.width / 2 - newWidth / 2, 0, newWidth, originalImage.size.height);
            }
            CGImageRef cgImgae = originalImage.CGImage;
            CGImageRef targetImage = CGImageCreateWithImageInRect(cgImgae, interceptRect);
            UIImage *resultImage = [UIImage imageWithCGImage:targetImage];
            CGImageRelease(targetImage);
            [imageView setImage:resultImage];
        }];
    }
}

#pragma mark - collection view datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!_sourceArray) {
        return 0;
    }
    return 200;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    NSInteger index = (indexPath.item + _pageOffset) % _sourceArrayCount;
    ScrollModel *model = _sourceArray[index];
    if (index < 3) {
        NSString *imageStr = [NSString stringWithFormat:@"NO.%ld", index + 1];
        cell.rankImageView.hidden = NO;
        [cell.rankImageView setImage:[UIImage imageNamed:imageStr]];
    } else {
        cell.rankImageView.hidden = YES;
    }
    cell.videoNameLabel.text = model.title;
    [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.perImg] placeholderImage:[UIImage imageNamed:@"首页banner头像"]];
    cell.uploadPersonLabel.text = model.petName;
    cell.playTimesLabel.text = [NSString stringWithFormat:@"播放：%@次", model.scanCount];
    if (model.isNeedPay) {
        cell.profitView.hidden = NO;
        CGSize size = [model.profit boundingRectWithSize:CGSizeMake(MAXFLOAT, 12) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:10], NSFontAttributeName, nil] context:nil].size;
        cell.walletLabelWidthConstraint.constant = size.width + 16;
        cell.profitViewWidthConstraint.constant = size.width + 30;
        cell.walletLabel.layer.cornerRadius = 6;
        cell.walletLabel.clipsToBounds = YES;
        cell.walletLabel.text = [NSString stringWithFormat:@"  %@", model.profit];
        cell.isFreeView.hidden = YES;
    } else {
        cell.profitView.hidden = YES;
        cell.isFreeView.hidden = NO;
    }
    if ([model.perType integerValue] > 2) {
        cell.perTypeImageView.hidden = YES;
    } else {
        cell.perTypeImageView.hidden = NO;
        if ([model.perType integerValue] == 2) {
            [cell.perTypeImageView setImage:[UIImage imageNamed:@"制作联盟"]];
        } else if ([model.perType integerValue] == 3) {
            [cell.perTypeImageView setImage:[UIImage imageNamed:@"自媒体"]];
        } else {
            [cell.perTypeImageView setImage:nil];
        }
    }
    cell.imageView.image = nil;
    [self setImageView:cell.imageView withInterceptedImageOfURL:model.imgPath];
    
    if (indexPath.item != _originalItem) {
        CATransform3D trans = CATransform3DIdentity;
        trans.m34 = 1.0 / -1000;
        trans = CATransform3DRotate(trans, M_PI/3, 0, indexPath.item < _originalItem ? 1 : -1, 0);
        trans = CATransform3DScale(trans, 0.8, 0.8, 0);
        cell.layer.transform = trans;
    }
    else{
        cell.layer.transform = CATransform3DIdentity;
    }
    return cell;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ScrollModel *model = _sourceArray[(indexPath.item + _pageOffset)  % _sourceArrayCount];
    if ([self.delegate respondsToSelector:@selector(circleView:clickedCellWithInfo:)]) {
        [self.delegate circleView:self clickedCellWithInfo:model];
    }

}

#pragma mark - collection cell delegate
- (void)cellClickedHeaderView:(PFCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    ScrollModel *model = _sourceArray[(indexPath.item + _pageOffset)  % _sourceArrayCount];
    if ([self.delegate respondsToSelector:@selector(circleView:clickedHeaderWithInfo:)]) {
        [self.delegate circleView:self clickedHeaderWithInfo:model];
    }
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (!_sourceArray) {
        return;
    }
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger currentPage = _originalItem + roundf((offset - _originalOffset) / (self.collectionView.bounds.size.width * 0.65 - 65));
    ScrollModel *model = _sourceArray[(currentPage + _pageOffset) % _sourceArrayCount];
    [self setBgImageView:_bgImageView withInterceptedImageOfURL:model.imgPath];
    
    self.pageOffset = _pageOffset + (currentPage % _sourceArrayCount - _originalItem % _sourceArrayCount);
    self.pageOffset = _pageOffset % _sourceArrayCount;
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_originalItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

@end
