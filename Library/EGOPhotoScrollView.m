//
//  EGOPhotoScrollView.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/11/10January11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EGOPhotoScrollView.h"
#import "EGOPhotoImageView.h"

@implementation EGOPhotoScrollView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.scrollEnabled = YES;
		self.pagingEnabled = NO;
		self.clipsToBounds = NO;
		self.maximumZoomScale = 3.0f;
		self.minimumZoomScale = 1.0f;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.alwaysBounceVertical = NO;
		self.alwaysBounceHorizontal = NO;
		self.bouncesZoom = YES;
		self.bounces = YES;
		self.scrollsToTop = NO;
		self.backgroundColor = [UIColor blackColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		
    }
    return self;
}

- (void)zoomRectWithCenter:(CGPoint)center{
	
	if (self.zoomScale > 1.0f) {
		//  zoom out
		[((EGOPhotoImageView*)self.superview) killScrollViewZoom];
	} else {
		//  zoom in
		CGFloat xCoor = center.x - 50.0f;
		CGFloat yCoor = center.y - 50.0f;
		
		if (xCoor < 0.0f) xCoor = 0.0f;
		if (yCoor < 0.0f) yCoor = 0.0f;
					
		[self zoomToRect:CGRectMake(xCoor, yCoor, 50.0f, 50.0f) animated:YES];
		
	}
}

- (void)toggleBars{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EGOPhotoViewToggleBars" object:nil];
}

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	
	if (touch.tapCount == 1) {
		[self performSelector:@selector(toggleBars) withObject:nil afterDelay:.2];
	} else if (touch.tapCount == 2) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleBars) object:nil];
		[self zoomRectWithCenter:[[touches anyObject] locationInView:self]];
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [super dealloc];
}


@end
