//
//  EGOPhotoImageView.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageLoader.h"

@class EGOPhoto, EGOPhotoScrollView, EGOPhotoCaptionView;

@interface EGOPhotoImageView : UIView <EGOImageLoaderObserver, UIScrollViewDelegate>{
@private
	EGOPhotoScrollView *_scrollView;
	EGOPhotoCaptionView *captionView;
	EGOPhoto *photo;
	UIImageView *_imageView;
	UIActivityIndicatorView *activityView;
	
	CGRect initImageViewFrame;

}

@property(nonatomic,retain) EGOPhoto *photo;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) EGOPhotoScrollView *scrollView;

- (void)setPhoto:(EGOPhoto*)aPhoto;
- (void)killScrollViewZoom;
- (void)layoutScrollViewAnimated:(BOOL)animated;
- (void)prepareForReusue;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

@end
