//
//  AppDelegate.m
//  TestFinal
//
//  Created by LIU ZHEon 14-4-30.
//
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PhotoStackView.h"



static CGFloat const PhotoRotationOffsetDefault = 4.0f;

@interface PhotoStackView()

@property (nonatomic, strong) NSArray *photoViews;

@end

@implementation PhotoStackView



CGFloat currentScale;
CGFloat currentRotation;

#pragma mark -
#pragma mark Getters and Setters

-(void)setDataSource:(id<PhotoStackViewDataSource>)dataSource {
    if(dataSource != _dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}

-(void)setPhotoViews:(NSArray *)photoViews {
    
    // Remove current photo views, ready to be replaced with the fresh batch
    
    for(UIView *view in self.photoViews) {
        [view removeFromSuperview];
    }
    
    
    for (UIView *view in photoViews) {
  
        
        if([photoViews indexOfObject:view] < [_photoViews count]) {
            UIView *existingViewAtIndex = [_photoViews objectAtIndex:[photoViews indexOfObject:view]];
            view.transform = existingViewAtIndex.transform;
        } else {
            [self makeCrooked:view animated:NO];
        }
        
        [self insertSubview:view atIndex:0];
        
    }
    
    _photoViews = photoViews;
}



-(void)setRotationOffset:(CGFloat)rotationOffset {
    if(rotationOffset != _rotationOffset) {
        _rotationOffset = rotationOffset;
        [self reloadData];
    }
}

-(UIColor *)highlightColor {
    if(!_highlightColor) {
        _highlightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
    }
    return _highlightColor;
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    UIImageView *topPhoto = [[self topPhoto].subviews lastObject];
    
    if(highlighted) {
        
        UIView *view = [[UIView alloc] initWithFrame:topPhoto.bounds];
        view.backgroundColor = self.highlightColor;
        [topPhoto addSubview:view];
        [topPhoto bringSubviewToFront:view];
    } else {
        [[topPhoto.subviews lastObject] removeFromSuperview];
    }
    
}



#pragma mark -
#pragma mark Animation

-(void)returnToCenter:(UIView *)photo {
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         photo.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                     }];
}

-(void)flickAway:(UIView *)photo withVelocity:(CGPoint)velocity {
    
    if ([self.delegate respondsToSelector:@selector(photoStackView:willFlickAwayPhotoFromIndex:toIndex:)]) {
        NSUInteger fromIndex = [self indexOfTopPhoto];
        NSUInteger toIndex = [self indexOfTopPhoto]+1;
        NSUInteger numberOfPhotos = [self.dataSource numberOfPhotosInPhotoStackView:self];
        if (toIndex >= numberOfPhotos) {
            toIndex = 0;
        }
        [self.delegate photoStackView:self willFlickAwayPhotoFromIndex:fromIndex toIndex:toIndex];
    }
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat xPos = (velocity.x < 0) ? CGRectGetMidX(self.bounds)-width : CGRectGetMidY(self.bounds)+width;
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         photo.center = CGPointMake(xPos, CGRectGetMidY(self.bounds));
                     }
                     completion:^(BOOL finished){
                         
                         [self makeCrooked:photo animated:YES];
                         [self sendSubviewToBack:photo];
                         [self makeStraight:[self topPhoto] animated:YES];
                         [self returnToCenter:photo];
                         
                         if ([self.delegate respondsToSelector:@selector(photoStackView:didRevealPhotoAtIndex:)]) {
                             [self.delegate photoStackView:self didRevealPhotoAtIndex:[self indexOfTopPhoto]];
                         }
                     }];
    
}

-(void)rotatePhoto:(UIView *)photo degrees:(NSInteger)degrees animated:(BOOL)animated {
    
    CGFloat radians = M_PI * degrees / 180.0;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    
    if(animated) {
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             photo.transform = transform;
                         }];
        
    } else {
        photo.transform = transform;
    }
    
}

-(void)makeCrooked:(UIView *)photo animated:(BOOL)animated {
    
    NSInteger min = -(self.rotationOffset);
    NSInteger max = self.rotationOffset;
    
    NSInteger degrees = (arc4random_uniform(max-min+1)) + min;
    [self rotatePhoto:photo degrees:degrees animated:animated];
    
}

-(void)makeStraight:(UIView *)photo animated:(BOOL)animated {
    [self rotatePhoto:photo degrees:0 animated:animated];
}



#pragma mark -
#pragma mark Gesture Handlers

-(void)photoPanned:(UIPanGestureRecognizer *)gesture {
    
    UIView *topPhoto = [self topPhoto];
    CGPoint velocity = [gesture velocityInView:self];
    CGPoint translation = [gesture translationInView:self];
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
        [self sendActionsForControlEvents:UIControlEventTouchCancel];
        
        if ([self.delegate respondsToSelector:@selector(photoStackView:willStartMovingPhotoAtIndex:)]) {
            [self.delegate photoStackView:self willStartMovingPhotoAtIndex:[self indexOfTopPhoto]];
        }
        
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        CGFloat xPos = topPhoto.center.x + translation.x;
        CGFloat yPos = topPhoto.center.y + translation.y;
        
        topPhoto.center = CGPointMake(xPos, yPos);
        [gesture setTranslation:CGPointMake(0, 0) inView:self];
        
        
    } else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        
        if(abs(velocity.x) > 200) {
            [self flickAway:topPhoto withVelocity:velocity];
            
        } else {
            [self returnToCenter:topPhoto];
        }
        
    }
    
}



- (void) rotate:(UIRotationGestureRecognizer *)recognizer{
    UIView *topPhoto = [self topPhoto];
    
    topPhoto.transform = CGAffineTransformRotate(
                                                        topPhoto.transform,
                                                        recognizer.rotation);
    recognizer.rotation = 0;
}

- (void) pinch:(UIPinchGestureRecognizer *)recognizer{
    UIView *topPhoto = [self topPhoto];
    topPhoto.transform = CGAffineTransformScale(topPhoto.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(photoStackView:didSelectPhotoAtIndex:)]) {
        [self sendActionsForControlEvents:UIControlStateHighlighted];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
}


#pragma mark -
#pragma mark Other Methods

-(void)flipToNextPhoto{
    [self flickAway:[self topPhoto] withVelocity:CGPointMake(-400, 0)];
    
    
}

-(void)goToPhotoAtIndex:(NSUInteger)index {
    for (UIView *view in self.photoViews) {
        if([self.photoViews indexOfObject:view] < index) {
            [self sendSubviewToBack:view];
        }
    }
    [self makeStraight:[self topPhoto] animated:NO];
}

-(NSUInteger)indexOfTopPhoto {
    //return (self.photoViews) ? [self.photoViews indexOfObject:[self topPhoto]] : 0;//show nextPhoto as topPhoto
    int value = (arc4random() % 10) + 1;//Randomlly show the TopPhoto
    return value;
    
}

-(UIView *)topPhoto {
    return [self.subviews objectAtIndex:[self.subviews count]-1];
}

-(void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    [super sendActionsForControlEvents:controlEvents];
    self.highlighted = (controlEvents == UIControlStateHighlighted) ? YES : NO;
}



#pragma mark -
#pragma mark Setup

-(void)reloadData {
    
    if (!self.dataSource) {

        self.photoViews = nil;
        return;
        
    }
    
    NSInteger numberOfPhotos = [self.dataSource numberOfPhotosInPhotoStackView:self];
    NSInteger topPhotoIndex  = [self indexOfTopPhoto];
    
    
    NSMutableArray *photoViewsMutable   = [[NSMutableArray alloc] initWithCapacity:numberOfPhotos];
    
    for (NSUInteger index = 0; index < numberOfPhotos; index++) {
        
        UIImage *image = [self.dataSource photoStackView:self photoForIndex:index];
        CGSize imageSize = image.size;
        if([self.dataSource respondsToSelector:@selector(photoStackView:photoSizeForIndex:)]){
            imageSize = [self.dataSource photoStackView:self photoSizeForIndex:index];
        }
        UIImageView *photoImageView     = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, imageSize}];
        photoImageView.image            = image;
        photoImageView.layer.shadowColor= [UIColor blackColor].CGColor;
        photoImageView.layer.shadowOpacity = 1.0;
        photoImageView.layer.shadowRadius = 3.0;
        photoImageView.layer.shadowOffset = CGSizeMake(0, 3);
        UIView *view                    = [[UIView alloc] initWithFrame:photoImageView.frame];
        view.layer.rasterizationScale   = [[UIScreen mainScreen] scale];
        view.layer.shouldRasterize      = YES; // rasterize the view for faster drawing and smooth edges
        
        
        
        [view addSubview:photoImageView];
        
        view.tag    = index;
        view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        [photoViewsMutable addObject:view];
        
    }
    
    // Photo views are added to subview in the photoView setter
    self.photoViews = photoViewsMutable; photoViewsMutable = nil;
    [self goToPhotoAtIndex:topPhotoIndex];
    
    
    
}

-(void)setup {
    

    self.rotationOffset = PhotoRotationOffsetDefault;
    
    
    // Add Pan Gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(photoPanned:)];
    [panGesture setMaximumNumberOfTouches:1];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    
    // Add Rotate Gesture
    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    self.multipleTouchEnabled = YES;
    [self addGestureRecognizer:rotateRecognizer];
    
    //Add Pinch Gesure
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinchRecognizer];
    
    
    
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}

-(void)dealloc {
    [self setPhotoViews:nil];
    //[self setBorderImage:nil];
    [self setHighlightColor:nil];
    
}

@end
