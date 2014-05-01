//
//  AppDelegate.m
//  TestFinal
//
//  Created by LIU ZHEon 14-4-30.
//
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoStackView.h"

@interface PhotoStackViewController : UIViewController <PhotoStackViewDataSource, PhotoStackViewDelegate>

@property (nonatomic, strong) PhotoStackView *photoStack;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
