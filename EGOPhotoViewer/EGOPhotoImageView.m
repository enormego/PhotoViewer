//
//  EGOPhotoImageView.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import "EGOPhotoImageView.h"
#import "EGOPhoto.h"
#import "EGOPhotoScrollView.h"
#import "EGOPhotoCaptionView.h"

#import <QuartzCore/QuartzCore.h>

#define kPhotoErrorPlaceholder [UIImage imageNamed:@"error_placeholder.png"]
#define kPhotoLoadingPlaceholder [UIImage imageNamed:@"photo_placeholder.png"]

#define ZOOM_VIEW_TAG 101

@interface EGOPhotoImageView (Private)

- (void)layoutScrollViewAnimated:(BOOL)animated;
- (void)layoutPhotoSubviews;

@end


@implementation EGOPhotoImageView 

@synthesize photo, imageView=_imageView, scrollView=_scrollView;;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
				
		self.backgroundColor = [UIColor blackColor];
		self.userInteractionEnabled = NO; // this will get set when the image is set
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		_scrollView = [[EGOPhotoScrollView alloc] initWithFrame:self.bounds];
		_scrollView.backgroundColor = [UIColor blackColor];
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.tag = ZOOM_VIEW_TAG;
		[_scrollView addSubview:_imageView];
		
		//captionView = [[EGOPhotoCaptionView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - (43.0f + 44.0f), self.frame.size.width, 43.0f)];
		//[self insertSubview:captionView atIndex:2];
		//[captionView release];

		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 11.0f, (CGRectGetHeight(self.frame) / 2) + 80.0f , 22.0f, 22.0f);
		[self addSubview:activityView];
		[activityView release];	
	}
    return self;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation{

	if (self.scrollView.zoomScale > 1.0f) {
		
		CGFloat height, width;
		height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
		width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
		self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
		
	} else {
		
		[self layoutPhotoSubviews];
		
	}
}

- (CABasicAnimation*)fadeAnimation{
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.fromValue = [NSNumber numberWithFloat:0.0f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.duration = .3f;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

	return animation;
}

- (void)setPhoto:(EGOPhoto*)aPhoto{
	
	if (aPhoto == nil) return; 
	if ([aPhoto isEqual:self.photo]) return;

	if (self.photo != nil) {
		[[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.photo.imageURL];
	}
	
	[photo release];
	photo = nil;
	photo = [aPhoto retain];
	
	self.imageView.image = [[EGOImageLoader sharedImageLoader] imageForURL:photo.imageURL shouldLoadWithObserver:self];
	
	if (self.imageView.image != nil) {
		[activityView stopAnimating];
		self.userInteractionEnabled = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:NO], @"failed", nil]];
		
	} else {
		[activityView startAnimating];
		self.userInteractionEnabled= NO;
		self.imageView.image = kPhotoLoadingPlaceholder;
	}
	
	[self layoutPhotoSubviews];
}

- (void)prepareForReusue{
	
	//  reset view
	self.photo = nil;
	self.tag = -1;
	
}

- (void)setupImageViewWithImage:(UIImage*)theImage {	
	
	[activityView stopAnimating];
	self.imageView.image = theImage; 
	[self layoutPhotoSubviews];

	[[self layer] addAnimation:[self fadeAnimation] forKey:@"opacity"];
	
	self.userInteractionEnabled = YES;

}

- (void)layoutPhotoSubviews{
	
	NSLog(@"layoutphotosubiviews");
	
	CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
	
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
	
	// center scrollView vertically or horizontally in superview
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
	
	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
	self.imageView.frame = self.scrollView.bounds;
	
	initImageViewFrame = self.scrollView.frame;
}


- (void)layoutScrollViewAnimated:(BOOL)animated{
	
	NSLog(@"layoutscrollview atZoomScale: %f animated: %@", self.scrollView.zoomScale, animated ? @"YES" : @"NO");
	
	if (self.scrollView.zoomScale > 1.0f) {
		
		return;
	}
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.0001];
	}
	
	CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
	
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
	
	// center scrollView vertically or horizontally in superview
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
	
	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
	self.imageView.frame = self.scrollView.bounds;
	

	NSLog(@"layout scrollview frame: %@", NSStringFromCGRect(self.scrollView.frame));
	
	
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark EGOImageLoader Callbacks

- (void)imageLoaderDidLoad:(NSNotification*)notification {	
	
	if ([notification userInfo] == nil) return;
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.photo.imageURL]) return;
	
	[self setupImageViewWithImage:[[notification userInfo] objectForKey:@"image"]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:NO], @"failed", nil]];
	
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
	
	if ([notification userInfo] == nil) return;
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.photo.imageURL]) return;
	
	self.imageView.image = kPhotoErrorPlaceholder;
	[self layoutScrollViewAnimated:NO];
	self.userInteractionEnabled = NO;
	[activityView stopAnimating];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:YES], @"failed", nil]];
	
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods

- (void)killScrollViewZoom{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1];
	
	if (self.scrollView.zoomScale > 1.0f) {
		
		CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
		CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
		
		CGFloat factor = MAX(hfactor, vfactor);
		
		CGFloat newWidth = self.imageView.image.size.width / factor;
		CGFloat newHeight = self.imageView.image.size.height / factor;
		
		CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
		CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
		
		self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	}
	
	[UIView commitAnimations];

	[self.scrollView setZoomScale:1.0f animated:YES];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return [self.scrollView viewWithTag:ZOOM_VIEW_TAG];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	if (scrollView.zooming) {
		
		//scrollView.contentOffset = CGPointMake(self.imageView.frame.size.width * .3, self.imageView.frame.size.height * .3);
		//NSLog(@"content: %f, %f", self.imageView.frame.size.width * .3f, self.imageView.frame.size.height * .3f);
		//NSLog(@"scrollviewdidscroll // zooming: %@", NSStringFromCGPoint(scrollView.contentOffset));
	}
	
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
	
	NSLog(@"SCALE: %f", scale);
			
	if (scrollView.zoomScale > 1.0f) {		
		CGFloat height, width, originX, originY;
		height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
		width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));

		
		if (CGRectGetMaxX(self.imageView.frame) > self.bounds.size.width) {
			width = CGRectGetWidth(self.bounds);
			originX = 0.0f;
		} else {
			width = CGRectGetMaxX(self.imageView.frame);
			
			if (self.imageView.frame.origin.x < 0.0f) {
				originX = 0.0f;
			} else {
				originX = self.imageView.frame.origin.x;
			}	
		}
		
		if (CGRectGetMaxY(self.imageView.frame) > self.bounds.size.height) {
			height = CGRectGetHeight(self.bounds);
			originY = 0.0f;
		} else {
			height = CGRectGetMaxY(self.imageView.frame);
			
			if (self.imageView.frame.origin.y < 0.0f) {
				originY = 0.0f;
			} else {
				originY = self.imageView.frame.origin.y;
			}
		}

		CGPoint contentOffset = self.scrollView.contentOffset;
		CGSize contentSize = self.scrollView.contentSize;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.01];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1];
		self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);	
		[UIView commitAnimations];
		NSLog(@"Height: %f, Width: %f", height, width);
		//self.scrollView.frame = CGRectMake(originX, originY, width, height);	

		
		
		[UIView commitAnimations];
		
		NSLog(@"ScrollView contentSize pre: %@", NSStringFromCGSize(contentSize));
		NSLog(@"Scrollview contentSize post: %@", NSStringFromCGSize(self.scrollView.contentSize));
		NSLog(@"Scrollview contentOffset pre: %@", NSStringFromCGPoint(contentOffset));
		NSLog(@"Scrollview contentOffset post: %@", NSStringFromCGPoint(self.scrollView.contentOffset));
		

	} else {
		[self layoutScrollViewAnimated:YES];
	}
}	


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	NSLog(@"dealloc EGOPhotoImageView");
	
	[[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.photo.imageURL];
	
	[_imageView release]; _imageView=nil;
	[_scrollView release]; _scrollView=nil;
	[photo release]; photo=nil;
    [super dealloc];
	
}


@end
