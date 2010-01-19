//
//  EGOPhotoController.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageLoader.h"
#import <MessageUI/MessageUI.h>

@class EGOPhotoImageView, EGOPhotoSource, EGOPhoto, EGOPhotoCaptionView;

@interface EGOPhotoViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
@private
	EGOPhotoSource *_photoSource;
	NSMutableArray *_photoViews;
	EGOPhotoCaptionView *_captionView;
	UIScrollView *_scrollView;	

	NSTimer *timer;	
	NSInteger pageIndex;
	BOOL rotating;
	
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
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;

@end