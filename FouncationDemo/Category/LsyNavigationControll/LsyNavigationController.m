//
//  LsyNavigationController.m
//  ManufacturingAlliance
//
//  Created by swkj_lsy on 16/11/1.
//  Copyright © 2016年 thidnet. All rights reserved.
//

#import "LsyNavigationController.h"

@interface LsyNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation LsyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.interactivePopGestureRecognizer.delegate = self;
    __weak LsyNavigationController *weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        
        self.delegate =  weakSelf;
        
    }
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated

{
    
    if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)]&&animated == YES ){
        
        self.interactivePopGestureRecognizer.enabled = NO;
    
        
        NSLog(@"第一次");
        
    }
    
    [super pushViewController:viewController animated:animated];
    
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated

{
    
    if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)]&& animated == YES ){
        
        self.interactivePopGestureRecognizer.enabled = NO;
        NSLog(@"第二次");
        
    }
    
    return [super popToRootViewControllerAnimated:animated];
    
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] ){
        
        self.interactivePopGestureRecognizer.enabled = NO;
        NSLog(@"第三次");
        
    }
    
    return [super popToViewController:viewController animated:animated];
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animate {
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        
        if (navigationController.childViewControllers.count == 1) {
            
            self.interactivePopGestureRecognizer.enabled = NO;
            NSLog(@"第4次");
            
        }else
            
            self.interactivePopGestureRecognizer.enabled = YES;
        NSLog(@"第5次");
        
    }
    NSLog(@"第6次");
    NSLog(@"child view count - %ld",navigationController.childViewControllers.count);
    
}

 


-(void)viewWillDisappear:(BOOL)animated{
    self.interactivePopGestureRecognizer.delegate = nil;
    NSLog(@"第7次");
        
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL ok = YES; // 默认为支持右滑反回
    if ([self.topViewController isKindOfClass:[LsyNavigationController class]]) {
        if ([self.topViewController respondsToSelector:@selector(gestureRecognizerShouldBegin)]) {
            LsyNavigationController *vc = (LsyNavigationController *)self.topViewController;
            ok = [vc gestureRecognizerShouldBegin];
            NSLog(@"第8次");
        }
    }
    return ok;
}
- (BOOL)gestureRecognizerShouldBegin {
    NSLog(@"第9次");
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
