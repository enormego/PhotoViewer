//
//  PVLabel.h
//  PhotoViewer
//
//  Created by Shaun Harrison on 11/24/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVLabel : UIView {
@private
	NSString* _text;
	UIFont* _font;
	UITextAlignment _textAlignment;
	UIColor* _textColor;
	CGSize _shadowOffset;
	UIColor* _shadowColor;
	UILineBreakMode _lineBreakMode;
	UIEdgeInsets _contentInset;
}

- (id)initWithText:(NSString*)text;

@property(nonatomic,copy) NSString* text;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,assign) UITextAlignment textAlignment;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,assign) CGSize shadowOffset;
@property(nonatomic,assign) UIColor* shadowColor;
@property(nonatomic,assign) UILineBreakMode lineBreakMode;
@property(nonatomic,assign) UIEdgeInsets contentInset;
@end
