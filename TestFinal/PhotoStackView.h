//
//  AppDelegate.m
//  TestFinal
//
//  Created by LIU ZHEon 14-4-30.
//
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoStackView;

@protocol PhotoStackViewDataSource <NSObject>

@required
- (NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStack;
- (UIImage *)photoStackView:(PhotoStackView *)photoStack photoForIndex:(NSUInteger)index;

@optional
- (CGSize)photoStackView:(PhotoStackView *)photoStack photoSizeForIndex:(NSUInteger)index;

@end


@protocol PhotoStackViewDelegate <NSObject>

@optional
-(void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index;
-(void)photoStackView:(PhotoStackView *)photoStackView willFlickAwayPhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
-(void)photoStackView:(PhotoStackView *)photoStackView didRevealPhotoAtIndex:(NSUInteger)index;
-(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index;

@end


@interface PhotoStackView : UIControl <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <PhotoStackViewDataSource> dataSource;
@property (weak, nonatomic) id <PhotoStackViewDelegate> delegate;
@property (nonatomic) CGFloat rotationOffset;
@property (nonatomic, strong) UIColor *highlightColor;

-(NSUInteger)indexOfTopPhoto;
-(void)goToPhotoAtIndex:(NSUInteger)index;
-(void)flipToNextPhoto;
-(void)reloadData;

@end
