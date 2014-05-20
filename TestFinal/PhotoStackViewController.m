//
//  AppDelegate.m
//  TestFinal
//
//  Created by LIU ZHEon 14-4-30.
//
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "PhotoStackViewController.h"

@interface PhotoStackViewController ()
    @property (nonatomic, strong) NSArray *photos;
    
    -(void)setup;
@end

@implementation PhotoStackViewController

@synthesize photoStack = _photoStack,
            pageControl = _pageControl;



#pragma mark -
#pragma mark Getters

-(NSArray *)photos {
    if(!_photos) {

        _photos = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"1.JPG"],
                   [UIImage imageNamed:@"2.JPG"],
                   [UIImage imageNamed:@"3.JPG"],
                   [UIImage imageNamed:@"4.JPG"],
                   [UIImage imageNamed:@"5.JPG"],
                   [UIImage imageNamed:@"6.JPG"],
                   [UIImage imageNamed:@"7.JPG"],
                   [UIImage imageNamed:@"8.JPG"],
                   [UIImage imageNamed:@"9.JPG"],
                   [UIImage imageNamed:@"10.JPG"],
                   nil];
        
    }
    return _photos;
}

- (NSArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}

-(PhotoStackView *)photoStack {
    if(!_photoStack) {        
        _photoStack = [[PhotoStackView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        _photoStack.center = CGPointMake(self.view.center.x, 170);
        _photoStack.dataSource = self;
        _photoStack.delegate = self;
    }
    
    return _photoStack;
}



#pragma mark -
#pragma mark Deck DataSource Protocol Methods

-(NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStack {
    return [self.photos count];
}

-(UIImage *)photoStackView:(PhotoStackView *)photoStack photoForIndex:(NSUInteger)index {
  
    
    return [self.photos objectAtIndex:index];
    //return [self.photos objectAtIndex:value];
}



#pragma mark -
#pragma mark Deck Delegate Protocol Methods

-(void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index {
    // User started moving a photo
}

-(void)photoStackView:(PhotoStackView *)photoStackView willFlickAwayPhotoAtIndex:(NSUInteger)index {
    // User flicked the photo away, revealing the next one in the stack
}

-(void)photoStackView:(PhotoStackView *)photoStackView didRevealPhotoAtIndex:(NSUInteger)index {
    self.pageControl.currentPage = index;
}

-(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index {
    }




#pragma mark -
#pragma mark Actions




#pragma mark -
#pragma mark Setup


-(void)setup {
    [self.view addSubview:self.photoStack];
    self.pageControl.numberOfPages = [self.photos count];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [self setup];
}

- (void)viewDidUnload {
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
