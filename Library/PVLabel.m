//
//  PVLabel.m
//  PhotoViewer
//
//  Created by Shaun Harrison on 11/24/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import "PVLabel.h"

@implementation PVLabel
@synthesize font=_font, text=_text, textAlignment=_textAlignment, textColor=_textColor, shadowOffset=_shadowOffset, shadowColor=_shadowColor, lineBreakMode=_lineBreakMode, contentInset=_contentInset;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.font = [UIFont boldSystemFontOfSize:12.0f];
		self.textAlignment = UITextAlignmentCenter;
		self.textColor = [UIColor blackColor];
		self.lineBreakMode = UILineBreakModeTailTruncation;
    }
	
    return self;
}

- (id)initWithText:(NSString*)text {
	if((self = [self initWithFrame:CGRectZero])) {
		self.text = text;
	}
	
	return self;
}

- (void)setText:(NSString *)text {
	[_text release];
	_text = [text copy];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing methods

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	if(!CGSizeEqualToSize(self.shadowOffset, CGSizeZero) && self.shadowColor) {
		CGContextSetShadowWithColor(context, CGSizeMake(self.shadowOffset.width, -self.shadowOffset.height), 0.0f, self.shadowColor.CGColor);
	}
	
	[self.textColor set];
	
	CGRect adjustedRect = rect;
	adjustedRect.origin.y += self.contentInset.top;
	adjustedRect.origin.x += self.contentInset.left;
	adjustedRect.size.height -= self.contentInset.top + self.contentInset.bottom;
	adjustedRect.size.width -= self.contentInset.left + self.contentInset.right;	

	[self.text drawInRect:adjustedRect withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
	
	CGContextRestoreGState(context);
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize adjustedSize = size;
	
	if(adjustedSize.height <= 0.0f) {
		adjustedSize.height = CGFLOAT_MAX;	
	}
	
	adjustedSize.height -= self.contentInset.top + self.contentInset.bottom;
	adjustedSize.width -= self.contentInset.left + self.contentInset.right;	
	
	CGSize fitSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(adjustedSize.width, adjustedSize.height) lineBreakMode:self.lineBreakMode];
	
	fitSize.height += self.contentInset.top + self.contentInset.bottom;
	fitSize.width += self.contentInset.left + self.contentInset.right;
	
	return fitSize;
}

#pragma mark -
#pragma mark Accessibility methods

- (BOOL)isAccessibilityElement {
	return YES;
}

- (NSString *)accessibilityLabel {
	return _text;
}

- (UIAccessibilityTraits)accessibilityTraits {
	return [super accessibilityTraits] | UIAccessibilityTraitStaticText;
}

#pragma mark -

- (void)dealloc {
	self.font = nil;
	self.text = nil;
	self.textColor = nil;
	self.shadowColor = nil;
    [super dealloc];
}


@end
