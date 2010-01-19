//
//  EGOPhotoCaptionView.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/16/10January16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EGOPhotoCaptionView.h"


@implementation EGOPhotoCaptionView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, self.frame.size.width - 40.0f, 40.0f)];
		_textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.textAlignment = UITextAlignmentCenter;
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.shadowColor = [UIColor blackColor];
		_textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		[self addSubview:_textLabel];
		[_textLabel release];
					  
    }
    return self;
}

- (void)layoutSubviews{
	[self setNeedsDisplay];
	_textLabel.frame = CGRectMake(20.0f, 0.0f, self.frame.size.width - 40.0f, 40.0f);
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor colorWithWhite:1.0f alpha:0.8f] setStroke];
	CGContextMoveToPoint(ctx, 0.0f, 0.0f);
	CGContextAddLineToPoint(ctx, self.frame.size.width, 0.0f);
	CGContextStrokePath(ctx);
	
}

- (void)setCaptionText:(NSString*)text{
	if (text == nil) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1f];
		self.alpha = 0.0f;
		[UIView commitAnimations];
		_textLabel.text = nil;	
		return;
	}

	self.alpha = 1.0f;
	_textLabel.text = text;
}

- (void)setCaptionHidden:(BOOL)hidden{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2f];
	
	if (hidden) {
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		self.frame = CGRectMake(0.0f, self.superview.frame.size.height, self.frame.size.width, self.frame.size.height);
		self.alpha = 0.0f;
	} else {
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		CGFloat toolbarSize = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 32.0f : 44.0f;
		self.frame = CGRectMake(0.0f, self.superview.frame.size.height - (toolbarSize + self.frame.size.height), self.frame.size.width, self.frame.size.height);
		if (_textLabel.text != nil) {
			self.alpha = 1.0f;
		}
	}
	
	[UIView commitAnimations];
}

- (void)dealloc {
    [super dealloc];
}


@end
