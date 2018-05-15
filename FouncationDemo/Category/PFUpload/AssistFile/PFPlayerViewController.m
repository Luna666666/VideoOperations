//
//  PFPlayerViewController.m
//  ManufacturingAlliance
//
//  Created by Ponfey on 2016/10/21.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "PFPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PFPlayerViewController ()

@property (nonatomic, strong) MPMoviePlayerController *player;

@end

@implementation PFPlayerViewController
-(void)viewWillDisappear:(BOOL)animated{
    [self.player stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _titleStr;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:_videoUrl];
    self.player.controlStyle = MPMovieControlStyleDefault;
    self.player.view.frame = self.view.bounds;
    [self.view addSubview:_player.view];
    
    [self.player play];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"返回"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(1, 0, -1, 0);
}

- (void)back {
    [self.player stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
