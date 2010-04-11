//
//  EGOPhotoController.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageLoader.h"
#import "EGOPhotoImageView.h"
#import "EGOCache.h"
#import "EGOPhoto.h"
#import "EGOPhotoSource.h"
#import "EGOPhotoCaptionView.h"
#import <MessageUI/MessageUI.h>

@class EGOPhotoImageView, EGOPhotoSource, EGOPhoto, EGOPhotoCaptionView;

@interface EGOPhotoViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
@private
	EGOPhotoSource *_photoSource;
	EGOPhotoCaptionView *_captionView;
	NSMutableArray *_photoViews;
	UIScrollView *_scrollView;	

	NSInteger _pageIndex;
	BOOL _rotating;
	BOOL _barsHidden;
	BOOL _popOver;
	
	UIBarButtonItem *leftButton;
	UIBarButtonItem *rightButton;
	UIBarButtonItem *actionButton;

	BOOL _storedOldStyles;
	UIStatusBarStyle _oldStatusBarSyle;
	UIBarStyle _oldNavBarStyle;
	BOOL _oldNavBarTranslucent;
	UIColor* _oldNavBarTintColor;	
	UIBarStyle _oldToolBarStyle;
	BOOL _oldToolBarTranslucent;
	UIColor* _oldToolBarTintColor;	
	BOOL _oldToolBarHidden;
}

- (id)initWithPhotoSource:(EGOPhotoSource*)aSource;  //  multiple photos
- (id)initWithImageURL:(NSURL*)aURL;  //  single photo view

@property(nonatomic,readonly) EGOPhotoSource *photoSource;
@property(nonatomic,retain) NSMutableArray *photoViews;
@property(nonatomic,retain) EGOPhotoCaptionView *captionView;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,assign) BOOL popOver;

- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setIsPopover:(BOOL)isPopover;  //  set this if presenting in a popover

@end