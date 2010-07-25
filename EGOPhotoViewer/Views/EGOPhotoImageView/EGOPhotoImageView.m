//
//  EGOPhotoImageView.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/13/2010.
//  Copyright (c) 2008-2009 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOPhotoImageView.h"

#define ZOOM_VIEW_TAG 101

@interface EGOPhotoImageView (Private)
- (void)layoutScrollViewAnimated:(BOOL)animated;
- (CABasicAnimation*)fadeAnimation;
@end


@implementation EGOPhotoImageView 

@synthesize photo=_photo;
@synthesize imageView=_imageView;
@synthesize scrollView=_scrollView;
@synthesize loading=_loading;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
				
		self.backgroundColor = [UIColor blackColor];
		self.userInteractionEnabled = NO; // this will get set when the image is loaded/set
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		_scrollView = [[EGOPhotoScrollView alloc] initWithFrame:self.bounds];
		_scrollView.backgroundColor = [UIColor blackColor];
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		
		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.tag = ZOOM_VIEW_TAG;
		[_scrollView addSubview:_imageView];

		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		
		CGFloat offset = 80.0f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			offset=120.0f;
		}
#endif
		_activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 11.0f, (CGRectGetHeight(self.frame) / 2) + offset , 22.0f, 22.0f);
		_activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:_activityView];
		[_activityView release];
		
	}
    return self;
}

- (void)setPhoto:(id <EGOPhoto>)aPhoto{
	
	if (!aPhoto) return; 
	if ([aPhoto isEqual:self.photo]) return;
	
	if (self.photo != nil) {
		[[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.photo.URL];
	}
	
	[_photo release], _photo = nil;
	_photo = [aPhoto retain];
	
	if (self.photo.image) {
		self.imageView.image = self.photo.image;
	} else {
		self.imageView.image = [[EGOImageLoader sharedImageLoader] imageForURL:self.photo.URL shouldLoadWithObserver:self];
	}
	
	if (self.imageView.image) {
		
		[_activityView stopAnimating];
		self.userInteractionEnabled = YES;
		
		_loading=NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:NO], @"failed", nil]];
		
		
	} else {
		
		_loading = YES;
		[_activityView startAnimating];
		self.userInteractionEnabled= NO;
		self.imageView.image = kEGOPhotoLoadingPlaceholder;
	}
	
	[self layoutScrollViewAnimated:NO];
}

- (void)setupImageViewWithImage:(UIImage*)theImage {	
	
	_loading = NO;
	[_activityView stopAnimating];
	self.imageView.image = theImage; 
	[self layoutScrollViewAnimated:NO];
	
	[[self layer] addAnimation:[self fadeAnimation] forKey:@"opacity"];
	self.userInteractionEnabled = YES;
	
}

- (void)prepareForReusue{
	
	//  reset view
	self.tag = -1;
	
}


#pragma mark -
#pragma mark Layout

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation{

	if (self.scrollView.zoomScale > 1.0f) {
		
		CGFloat height, width;
		height = MIN(CGRectGetHeight(self.imageView.frame) + self.imageView.frame.origin.x, CGRectGetHeight(self.bounds));
		width = MIN(CGRectGetWidth(self.imageView.frame) + self.imageView.frame.origin.y, CGRectGetWidth(self.bounds));
		self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
		
	} else {
		[self layoutScrollViewAnimated:NO];
	}
}

- (void)layoutScrollViewAnimated:(BOOL)animated{

	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.0001];
	}
	
	CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
	
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
	
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;
	
	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
	self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
	self.imageView.frame = self.scrollView.bounds;

	if (animated) {
		[UIView commitAnimations];
	}
}


#pragma mark -
#pragma mark Animation

- (CABasicAnimation*)fadeAnimation{
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.fromValue = [NSNumber numberWithFloat:0.0f];
	animation.toValue = [NSNumber numberWithFloat:1.0f];
	animation.duration = .3f;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	
	return animation;
}


#pragma mark -
#pragma mark EGOImageLoader Callbacks

- (void)imageLoaderDidLoad:(NSNotification*)notification {	
	
	if ([notification userInfo] == nil) return;
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.photo.URL]) return;
	
	[self setupImageViewWithImage:[[notification userInfo] objectForKey:@"image"]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:NO], @"failed", nil]];
	
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
	
	if ([notification userInfo] == nil) return;
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.photo.URL]) return;
	
	self.imageView.image = kEGOPhotoErrorPlaceholder;
	self.photo.failed = YES;
	[self layoutScrollViewAnimated:NO];
	self.userInteractionEnabled = NO;
	[_activityView stopAnimating];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:YES], @"failed", nil]];
	
}


#pragma mark -
#pragma mark UIScrollView Delegate Methods

- (void)reallyKillZoom{
	
	[self.scrollView setZoomScale:1.0f animated:NO];
	self.imageView.frame = self.scrollView.bounds;
	[self layoutScrollViewAnimated:NO];
}

- (void)killScrollViewZoom{
	
	if (!self.scrollView.zoomScale > 1.0f) return;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDidStopSelector:@selector(reallyKillZoom)];
	[UIView setAnimationDelegate:self];

	CGFloat hfactor = self.imageView.image.size.width / self.frame.size.width;
	CGFloat vfactor = self.imageView.image.size.height / self.frame.size.height;
	
	CGFloat factor = MAX(hfactor, vfactor);
		
	CGFloat newWidth = self.imageView.image.size.width / factor;
	CGFloat newHeight = self.imageView.image.size.height / factor;
		
	CGFloat leftOffset = (self.frame.size.width - newWidth) / 2;
	CGFloat topOffset = (self.frame.size.height - newHeight) / 2;

	self.scrollView.frame = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
	self.imageView.frame = self.scrollView.bounds;
	[UIView commitAnimations];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return [self.scrollView viewWithTag:ZOOM_VIEW_TAG];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
			
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

		CGRect frame = self.scrollView.frame;
		self.scrollView.frame = CGRectMake((self.bounds.size.width / 2) - (width / 2), (self.bounds.size.height / 2) - (height / 2), width, height);
		if (!CGRectEqualToRect(frame, self.scrollView.frame)) {		
			
			CGFloat offsetY, offsetX;

			if (frame.origin.y < self.scrollView.frame.origin.y) {
				offsetY = self.scrollView.contentOffset.y - (self.scrollView.frame.origin.y - frame.origin.y);
			} else {				
				offsetY = self.scrollView.contentOffset.y - (frame.origin.y - self.scrollView.frame.origin.y);
			}
			
			if (frame.origin.x < self.scrollView.frame.origin.x) {
				offsetX = self.scrollView.contentOffset.x - (self.scrollView.frame.origin.x - frame.origin.x);
			} else {				
				offsetX = self.scrollView.contentOffset.x - (frame.origin.x - self.scrollView.frame.origin.x);
			}

			if (offsetY < 0) offsetY = 0;
			if (offsetX < 0) offsetX = 0;
			
			self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
		}

	} else {
		[self layoutScrollViewAnimated:YES];
	}
}	


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	if (_photo) {
		[[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.photo.URL];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_imageView release]; _imageView=nil;
	[_scrollView release]; _scrollView=nil;
	[_photo release]; _photo=nil;
    [super dealloc];
	
}


@end
