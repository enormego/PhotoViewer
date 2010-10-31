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

#define ZOOM_VIEW_TAG 0x101

@interface RotateGesture : UIRotationGestureRecognizer {}
@end

@implementation RotateGesture
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer*)gesture{
	return NO;
}
- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
	return YES;
}
@end


@interface EGOPhotoImageView (Private)
- (void)layoutScrollViewAnimated:(BOOL)animated;
- (void)handleFailedImage;
- (void)setupImageViewWithImage:(UIImage *)aImage;
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
		self.userInteractionEnabled = NO;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.opaque = YES;
		
		EGOPhotoScrollView *scrollView = [[EGOPhotoScrollView alloc] initWithFrame:self.bounds];
		scrollView.backgroundColor = [UIColor blackColor];
		scrollView.opaque = YES;
		scrollView.delegate = self;
		[self addSubview:scrollView];
		_scrollView = [scrollView retain];
		[scrollView release];

		UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		imageView.opaque = YES;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		imageView.tag = ZOOM_VIEW_TAG;
		[_scrollView addSubview:imageView];
		_imageView = [imageView retain];
		[imageView release];
		
		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityView.frame = CGRectMake((CGRectGetWidth(self.frame) / 2) - 11.0f, CGRectGetHeight(self.frame) - 100.0f , 22.0f, 22.0f);
		activityView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:activityView];
		_activityView = [activityView retain];
		[activityView release];
		
		RotateGesture *gesture = [[RotateGesture alloc] initWithTarget:self action:@selector(rotate:)];
		[self addGestureRecognizer:gesture];
		[gesture release];
		
	}
    return self;
}

- (void)layoutSubviews{
	[super layoutSubviews];
		
	if (_scrollView.zoomScale == 1.0f) {
		[self layoutScrollViewAnimated:YES];
	}
	
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
		
		if ([self.photo.URL isFileURL]) {
			
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
			
			NSError *error = nil;
			NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.photo.URL path] error:&error];
			NSInteger fileSize = [[attributes objectForKey:NSFileSize] integerValue];

			if (fileSize >= 1048576 && [[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) {
								
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
					
					UIImage *_image = nil;
					NSData *_data = [NSData dataWithContentsOfURL:self.photo.URL];
					if (!_data) {
						[self handleFailedImage];
					} else {
						_image = [UIImage imageWithData:_data];
					}
					
					dispatch_async(dispatch_get_main_queue(), ^{
						
						if (_image!=nil) {
							[self setupImageViewWithImage:_image];
						}
						
						
					});
								   
				});
		
			} else {
				
				self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photo.URL]];
				
			}

#else
			self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photo.URL]];
#endif
			
			
		} else {
			self.imageView.image = [[EGOImageLoader sharedImageLoader] imageForURL:self.photo.URL shouldLoadWithObserver:self];
		}
		
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

- (void)setupImageViewWithImage:(UIImage*)aImage {	
	if (!aImage) return; 

	_loading = NO;
	[_activityView stopAnimating];
	self.imageView.image = aImage; 
	[self layoutScrollViewAnimated:NO];
	
	[[self layer] addAnimation:[self fadeAnimation] forKey:@"opacity"];
	self.userInteractionEnabled = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:NO], @"failed", nil]];
	
}

- (void)prepareForReusue{
	
	//  reset view
	self.tag = -1;
	
}

- (void)handleFailedImage{
	
	self.imageView.image = kEGOPhotoErrorPlaceholder;
	self.photo.failed = YES;
	[self layoutScrollViewAnimated:NO];
	self.userInteractionEnabled = NO;
	[_activityView stopAnimating];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoDidFinishLoading" object:[NSDictionary dictionaryWithObjectsAndKeys:self.photo, @"photo", [NSNumber numberWithBool:YES], @"failed", nil]];
	
}


#pragma mark -
#pragma mark Parent Controller Fading

- (void)fadeView{
	
	self.backgroundColor = [UIColor clearColor];
	self.superview.backgroundColor = self.backgroundColor;
	self.superview.superview.backgroundColor = self.backgroundColor;
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
	[animation setValue:[NSNumber numberWithInt:101] forKey:@"AnimationType"];
	animation.delegate = self;
	animation.fromValue = (id)[UIColor clearColor].CGColor;
	animation.toValue = (id)[UIColor blackColor].CGColor;
	animation.duration = 0.4f;
	[self.layer addAnimation:animation forKey:@"FadeAnimation"];
	
	
}

- (void)resetBackgroundColors{
	
	self.backgroundColor = [UIColor blackColor];
	self.superview.backgroundColor = self.backgroundColor;
	self.superview.superview.backgroundColor = self.backgroundColor;

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
	self.scrollView.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
	self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
	self.imageView.frame = self.scrollView.bounds;


	if (animated) {
		[UIView commitAnimations];
	}
}

- (CGSize)sizeForPopover{
	
	CGSize popoverSize = EGOPV_MAX_POPOVER_SIZE;
	
	if (!self.imageView.image) {
		return popoverSize;
	}
	
	CGSize imageSize = self.imageView.image.size;
	
	if(imageSize.width > popoverSize.width || imageSize.height > popoverSize.height) {
		
		if(imageSize.width > imageSize.height) {
			popoverSize.height = floorf((popoverSize.width * imageSize.height) / imageSize.width);
		} else {
			popoverSize.width = floorf((popoverSize.height * imageSize.width) / imageSize.height);
		}
		
	} else {
		
		popoverSize = imageSize;
		
	}
	
	if (popoverSize.width < EGOPV_MIN_POPOVER_SIZE.width || popoverSize.height < EGOPV_MIN_POPOVER_SIZE.height) {
		
		CGFloat hfactor = popoverSize.width / EGOPV_MIN_POPOVER_SIZE.width;
		CGFloat vfactor = popoverSize.height / EGOPV_MIN_POPOVER_SIZE.height;
		
		CGFloat factor = MAX(hfactor, vfactor);
		
		CGFloat newWidth = popoverSize.width / factor;
		CGFloat newHeight = popoverSize.height / factor;
		
		popoverSize.width = newWidth;
		popoverSize.height = newHeight;
		
	} 
	
	
	return popoverSize;
	
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
	
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
	
	if ([notification userInfo] == nil) return;
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.photo.URL]) return;
	
	[self handleFailedImage];
	
}


#pragma mark -
#pragma mark UIScrollView Delegate Methods

- (void)killZoomAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	
	if([finished boolValue]){
		
		[self.scrollView setZoomScale:1.0f animated:NO];
		self.imageView.frame = self.scrollView.bounds;
		[self layoutScrollViewAnimated:NO];
		
	}
	
}

- (void)killScrollViewZoom{
	
	if (!self.scrollView.zoomScale > 1.0f) return;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDidStopSelector:@selector(killZoomAnimationDidStop:finished:context:)];
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

- (CGRect)frameToFitCurrentView{
	
	CGFloat heightFactor = self.imageView.image.size.height / self.frame.size.height;
	CGFloat widthFactor = self.imageView.image.size.width / self.frame.size.width;
	
	CGFloat scaleFactor = MAX(heightFactor, widthFactor);
	
	CGFloat newHeight = self.imageView.image.size.height / scaleFactor;
	CGFloat newWidth = self.imageView.image.size.width / scaleFactor;
	
	
	CGRect rect = CGRectMake((self.frame.size.width - newWidth)/2, (self.frame.size.height-newHeight)/2, newWidth, newHeight);
	
	return rect;
	
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
		self.scrollView.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
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
#pragma mark RotateGesture

- (void)rotate:(UIRotationGestureRecognizer*)gesture{

	if (gesture.state == UIGestureRecognizerStateBegan) {
		
		[self.layer removeAllAnimations];
		_beginRadians = gesture.rotation;
		self.layer.transform = CATransform3DMakeRotation(_beginRadians, 0.0f, 0.0f, 1.0f);
		
	} else if (gesture.state == UIGestureRecognizerStateChanged) {
		
		self.layer.transform = CATransform3DMakeRotation((_beginRadians + gesture.rotation), 0.0f, 0.0f, 1.0f);

	} else {
		
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
		animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		animation.duration = 0.3f;
		animation.removedOnCompletion = NO;
		animation.fillMode = kCAFillModeForwards;
		animation.delegate = self;
		[animation setValue:[NSNumber numberWithInt:202] forKey:@"AnimationType"];
		[self.layer addAnimation:animation forKey:@"RotateAnimation"];
		
	} 

	
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
	
	if (flag) {
		
		if ([[anim valueForKey:@"AnimationType"] integerValue] == 101) {
			
			[self resetBackgroundColors];
			
		} else if ([[anim valueForKey:@"AnimationType"] integerValue] == 202) {
			
			self.layer.transform = CATransform3DIdentity;
			
		}
	}
	
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	if (_photo) {
		[[EGOImageLoader sharedImageLoader] cancelLoadForURL:self.photo.URL];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_activityView release], _activityView=nil;
	[_imageView release]; _imageView=nil;
	[_scrollView release]; _scrollView=nil;
	[_photo release]; _photo=nil;
    [super dealloc];
	
}


@end
