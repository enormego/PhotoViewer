//
//  EGOPhotoController.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import "EGOPhotoViewController.h"
#import "EGOPhotoImageView.h"
#import "EGOCache.h"
#import "EGOPhoto.h"
#import "EGOPhotoSource.h"
#import "EGOPhotoCaptionView.h"

#define IMAGE_GAP 30

@interface EGOPhotoViewController (Private)
- (void)loadScrollViewWithPage:(NSInteger)page;
- (void)layoutScrollViewSubviewsAnimated:(BOOL)animated;
- (void)setupScrollViewContentSize;
- (void)setNavTitle;
- (void)queueReusablePhotoViewAtIndex:(NSInteger)theIndex;
- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (NSInteger)centerPhotoIndex;
@end


@implementation EGOPhotoViewController

@synthesize scrollView=_scrollView, photoSource=_photoSource, photoViews=_photoViews, captionView=_captionView, popOver=_popOver;

- (id)init{
	if (self = [super init]) {
		
		self.wantsFullScreenLayout = YES;
		//self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:@"EGOPhotoViewToggleBars" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoViewDidFinishLoading:) name:@"EGOPhotoDidFinishLoading" object:nil];
		
		_rotating=NO;
		_barsHidden=NO;
		_popOver=NO;
		_pageIndex=0;
		
	}
	return self;
}

- (id)initWithPhotoSource:(EGOPhotoSource*)aSource{
	if (self = [self init]) {
		_photoSource = [aSource retain];
				
		//  load photoviews lazily
		NSMutableArray *views = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < [self.photoSource count]; i++) {
			[views addObject:[NSNull null]];
		}
		self.photoViews = views;
		[views release];

		_captionView = [[EGOPhotoCaptionView alloc] initWithFrame:CGRectZero];
		[self.view insertSubview:_captionView atIndex:4];
	}
	
	return self;
}

- (id)initWithImageURL:(NSURL*)aURL {
	
	EGOPhoto *aPhoto = [[EGOPhoto alloc] initWithImageURL:aURL];
	EGOPhotoSource *source = [[[EGOPhotoSource alloc] initWithEGOPhotos:[NSArray arrayWithObject:aPhoto]] autorelease];
	[aPhoto release];
	
	return [self initWithPhotoSource:source];
}


#pragma mark -
#pragma mark View Controller Methods

- (NSArray*)photoToolbarItems{
	
	if ([self.photoSource count] > 1) {
		
		UIBarButtonItem *flexableSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem *fixedSpaceCenter = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		fixedSpaceCenter.width = 80.0f;
		UIBarButtonItem *fixedSpaceLeft = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		fixedSpaceLeft.width = 40.0f;
		actionButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"actionButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionButtonHit:)] autorelease];
		
		leftButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveBack:)] autorelease];
		rightButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moveForward:)] autorelease];
		
		return [NSArray arrayWithObjects:fixedSpaceLeft, flexableSpace, leftButton, fixedSpaceCenter, rightButton, flexableSpace, actionButton, nil];
		
	}
	
	return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	self.wantsFullScreenLayout = YES;

	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		_scrollView.delegate=self;
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_scrollView.multipleTouchEnabled=YES;
		_scrollView.scrollEnabled=YES;
		_scrollView.directionalLockEnabled=YES;
		_scrollView.canCancelContentTouches=YES;
		_scrollView.delaysContentTouches=YES;
		_scrollView.clipsToBounds=YES;
		_scrollView.alwaysBounceHorizontal=YES;
		_scrollView.bounces=YES;
		_scrollView.pagingEnabled=YES;
		_scrollView.showsVerticalScrollIndicator=NO;
		_scrollView.showsHorizontalScrollIndicator=NO;
		_scrollView.backgroundColor = self.view.backgroundColor;
		[self.view addSubview:_scrollView];
	}
	
	
	//[self setupScrollViewContentSize];
	[self setToolbarItems:[self photoToolbarItems]]; 
	[self moveToPhotoAtIndex:0 animated:NO];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
		self.navigationItem.rightBarButtonItem = doneButton;
		[doneButton release];
	}
#endif
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];

	if(!_storedOldStyles) {
		_oldStatusBarSyle = [UIApplication sharedApplication].statusBarStyle;
		
		_oldNavBarTintColor = [self.navigationController.navigationBar.tintColor retain];
		_oldNavBarStyle = self.navigationController.navigationBar.barStyle;
		_oldNavBarTranslucent = self.navigationController.navigationBar.translucent;
		
		_oldToolBarTintColor = [self.navigationController.toolbar.tintColor retain];
		_oldToolBarStyle = self.navigationController.toolbar.barStyle;
		_oldToolBarTranslucent = self.navigationController.toolbar.translucent;
		_oldToolBarHidden = [self.navigationController isToolbarHidden];
		
		_storedOldStyles = YES;
	}	
	
	self.navigationController.navigationBar.tintColor = nil;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;

	self.navigationController.toolbar.tintColor = nil;
	self.navigationController.toolbar.barStyle = UIBarStyleBlack;
	self.navigationController.toolbar.translucent = YES;
	
	[self.navigationController setToolbarHidden:NO animated:NO];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	}
#else
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
#endif
	
	[self setupScrollViewContentSize];

}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	self.navigationController.navigationBar.barStyle = _oldNavBarStyle;
	self.navigationController.navigationBar.tintColor = _oldNavBarTintColor;
	self.navigationController.navigationBar.translucent = _oldNavBarTranslucent;
	
	if(!_oldToolBarHidden) {
		self.navigationController.toolbar.barStyle = _oldNavBarStyle;
		self.navigationController.toolbar.tintColor = _oldNavBarTintColor;
		self.navigationController.toolbar.translucent = _oldNavBarTranslucent;
	}

	[self setBarsHidden:NO animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
#endif
   	return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	_rotating = YES;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		//self.scrollView.contentSize = CGSizeMake(480.0f * [self.photoSource count], 320.0f);
	}
	
	//  set side views hidden during rotation animation
	NSInteger count = 0;
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			if (count != _pageIndex) {
				[view setHidden:YES];
			}
		}
		count++;
	}
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			[view rotateToOrientation:toInterfaceOrientation];
		}
	}
	
	_captionView.frame = CGRectMake(0.0f, self.view.frame.size.height - (self.navigationController.toolbar.frame.size.height + 40.0f), self.view.frame.size.width, 40.0f);
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	
	//self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [self.photoSource count], self.scrollView.bounds.size.height);

	[self setupScrollViewContentSize];
	[self moveToPhotoAtIndex:_pageIndex animated:NO];
	[self.scrollView scrollRectToVisible:((EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).frame animated:YES];
	
	//  unhide side views
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			[view setHidden:NO];
		}
	}
	_rotating = NO;
}

- (void)done:(id)sender{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Bar/Caption Methods

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated{
	if (_popOver) return; 
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade]; //UIStatusBarAnimationFade
#else
	[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:animated];
#endif
	
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated{
	if (hidden&&_barsHidden) return;
	
	[self setStatusBarHidden:hidden animated:animated];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		if (animated) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3f];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		}
	
		//self.captionView.alpha = hidden ? 0.0f : 1.0f;
		[self.captionView setCaptionHidden:hidden];
		
		if (!_popOver) {
			self.navigationController.navigationBar.alpha = hidden ? 0.0f : 1.0f;
			self.navigationController.toolbar.alpha = hidden ? 0.0f : 1.0f;
		}
		
		if (animated) {
			[UIView commitAnimations];
		}
		
	} else {
		[self.captionView setCaptionHidden:hidden];
		[self.navigationController setNavigationBarHidden:hidden animated:animated];
		[self.navigationController setToolbarHidden:hidden animated:animated];
	}
#else
	[self.captionView setCaptionHidden:hidden];
	[self.navigationController setNavigationBarHidden:hidden animated:animated];
	[self.navigationController setToolbarHidden:hidden animated:animated];
#endif
	
	_barsHidden=hidden;
}

- (void)toggleBarsNotification:(NSNotification*)notification{
	[self setBarsHidden:!_barsHidden animated:YES];
}

- (void)setNavTitle{
	if ([self.photoSource count] > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", _pageIndex+1, [self.photoSource count]];
	} else {
		self.title = @"";
	}
}

- (void)setCaptionTitle{
	[self.captionView setCaptionText:[[self.photoSource photoAtIndex:[self centerPhotoIndex]] imageName]];
}

- (void)setIsPopover:(BOOL)isPopover{
	
	_popOver=isPopover;
	if (isPopover) {
		[self.navigationController setToolbarHidden:YES animated:NO];
	}
	
}


#pragma mark -
#pragma mark Photo View Methods

- (void)photoViewDidFinishLoading:(NSNotification*)notification{
	
	if (notification == nil) return;
	
	if ([((EGOPhoto*)[[notification object] objectForKey:@"photo"]) isEqual:[self.photoSource photoAtIndex:[self centerPhotoIndex]]]) {
		if ([[[notification object] objectForKey:@"failed"] boolValue]) {
			if (_barsHidden) {
				[self setBarsHidden:NO animated:YES];
			} 
		} else {
			[self setCaptionTitle];
		} 
	}
}

- (NSInteger)centerPhotoIndex{
	CGFloat pageWidth = self.scrollView.frame.size.width;
	return floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)moveForward:(id)sender{
	[self moveToPhotoAtIndex:[self centerPhotoIndex]+1 animated:NO];	
}

- (void)moveBack:(id)sender{
	[self moveToPhotoAtIndex:[self centerPhotoIndex]-1 animated:NO];
}

- (void)moveToPhotoAtIndex:(NSInteger)index animated:(BOOL)animated{

	_pageIndex = index;
	
	if ([self.photoSource count] > 1) {
		leftButton.enabled = !(index-1 < 0);
		rightButton.enabled = !(index+1 >= [self.photoSource count]);
	}
		
	[self queueReusablePhotoViewAtIndex:index];
	
	[self loadScrollViewWithPage:index-1];
	[self loadScrollViewWithPage:index];
	[self loadScrollViewWithPage:index+1];

	[self.scrollView scrollRectToVisible:((EGOPhotoImageView*)[self.photoViews objectAtIndex:index]).frame animated:animated];
	[self setNavTitle];
	
	if ([[self.photoSource photoAtIndex:_pageIndex] didFail]) {
		[self setBarsHidden:NO animated:YES];
	}
	
	//  reset any zoomed side views
	if (index + 1 < [self.photoSource count] && (NSNull*)[self.photoViews objectAtIndex:index+1] != [NSNull null]) {
		[((EGOPhotoImageView*)[self.photoViews objectAtIndex:index+1]) killScrollViewZoom];
	} 
	if (index - 1 >= 0 && (NSNull*)[self.photoViews objectAtIndex:index-1] != [NSNull null]) {
		[((EGOPhotoImageView*)[self.photoViews objectAtIndex:index-1]) killScrollViewZoom];
	} 	
	
	[self setCaptionTitle];
}

- (void)layoutScrollViewSubviewsAnimated:(BOOL)animated{
	
    NSInteger page = [self centerPhotoIndex];
	CGRect imageFrame = self.scrollView.frame;
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.1];
	}
	
		//  layout center
		if (page >= 0 && page < [self.photoSource count]){
			if ([self.photoViews objectAtIndex:page] != [NSNull null]){
				[((EGOPhotoImageView*)[self.photoViews objectAtIndex:page]) setFrame:CGRectMake(imageFrame.size.width * page, 0.0f, imageFrame.size.width, imageFrame.size.height)];
			}
		}
	
		//  layout left
		if (page-1 >= 0){
			if (page-1  >= 0 && [self.photoViews objectAtIndex:page -1] != [NSNull null]){
				[((EGOPhotoImageView*)[self.photoViews objectAtIndex:page -1]) setFrame:CGRectMake((imageFrame.size.width * (page -1)) - IMAGE_GAP, 0.0f, imageFrame.size.width, imageFrame.size.height)];
			}
		}
		
		//  layout right
		if (page+1 <= [self.photoSource count]) 
			if (page+1 < [self.photoSource count] && [self.photoViews objectAtIndex:page +1] != [NSNull null]){
				[((EGOPhotoImageView*)[self.photoViews objectAtIndex:page +1]) setFrame:CGRectMake((imageFrame.size.width * (page +1)) + IMAGE_GAP, 0.0f, imageFrame.size.width, imageFrame.size.height)];		
			}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)setupScrollViewContentSize{
	
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	screenFrame = self.view.bounds;
	CGFloat toolbarSize = self.navigationController.toolbar.frame.size.height;
	if (_popOver) {
		toolbarSize=0.0f;
	}
	
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		self.scrollView.contentSize = CGSizeMake(screenFrame.size.width * [self.photoSource count], screenFrame.size.height);
		_captionView.frame = CGRectMake(0.0f, screenFrame.size.height - (toolbarSize + 40.0f), screenFrame.size.width, 40.0f);
	} else {
		self.scrollView.contentSize = CGSizeMake(screenFrame.size.width * [self.photoSource count], screenFrame.size.height);
		_captionView.frame = CGRectMake(0.0f, screenFrame.size.height - (toolbarSize + 40.0f), screenFrame.size.width, 40.0f);
	}

	
}

- (void)queueReusablePhotoViewAtIndex:(NSInteger)theIndex{
	NSInteger count = 0;
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			if (count > theIndex+1 || count < theIndex-1) {
				[view prepareForReusue];
				[view removeFromSuperview];
			} else {
				view.tag = 0;
			}
	
		} 
		count++;
	}	
}

- (EGOPhotoImageView*)dequeueReusablePhotoView{
	NSInteger count = 0;
	for (EGOPhotoImageView *view in self.photoViews){
		if ([view isKindOfClass:[EGOPhotoImageView class]]) {
			if (view.superview == nil) {
				view.tag = count;
				return view;
			}
		}
		count ++;
	}	
	return nil;
}

- (void)loadScrollViewWithPage:(NSInteger)page {
	
    if (page < 0) return;
    if (page >= [self.photoSource count]) return;
		
    // replace the placeholder if necessary 	
	EGOPhotoImageView * photoView = [self.photoViews objectAtIndex:page];
	if ((NSNull*)photoView == [NSNull null]) {
		//  recycle an image view if one is free
		photoView = [self dequeueReusablePhotoView];
		if (photoView != nil) {
			[self.photoViews exchangeObjectAtIndex:photoView.tag withObjectAtIndex:page];
			photoView = [self.photoViews objectAtIndex:page];
		}
	}
	
	//  create a new image view if necessary 
	if (photoView == nil || (NSNull*)photoView == [NSNull null]) {
		photoView = [[EGOPhotoImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
		[self.photoViews replaceObjectAtIndex:page withObject:photoView];
		[photoView release];
	} 
	
	[photoView setPhoto:((EGOPhoto*)[self.photoSource photoAtIndex:page])];

    // add the image view to the scroll view if necessary
    if (photoView.superview == nil) {
		[self.scrollView addSubview:photoView];
	}
	
	//  layout image views frame
	CGRect frame = self.scrollView.frame;
	NSInteger centerPageIndex = _pageIndex;
	CGFloat xOrigin = (frame.size.width * page);
	if (page > centerPageIndex) {
		xOrigin = (frame.size.width * page) + IMAGE_GAP;
	} else if (page < centerPageIndex) {
		xOrigin = (frame.size.width * page) - IMAGE_GAP;
	}
		
	frame.origin.x = xOrigin;
	frame.origin.y = 0;
	photoView.frame = frame;
}


#pragma mark -
#pragma mark ScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {

	if (_pageIndex != [self centerPhotoIndex] && !_rotating) {
		NSInteger newIndex = [self centerPhotoIndex];
		if (newIndex >= [self.photoSource count] || newIndex < 0) {
			return;
		}
		[self setBarsHidden:YES animated:YES];
		_pageIndex = newIndex;
		[self layoutScrollViewSubviewsAnimated:YES];
		[self setNavTitle];
		[self.captionView setCaptionText:@""];
		

		if ((NSNull*)[self.photoViews objectAtIndex:_pageIndex] == [NSNull null]) {
			[self loadScrollViewWithPage:_pageIndex];
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	NSInteger newIndex = [self centerPhotoIndex];
	if (newIndex >= [self.photoSource count] || newIndex < 0) {
		return;
	}
	[self moveToPhotoAtIndex:[self centerPhotoIndex] animated:YES];
	[self layoutScrollViewSubviewsAnimated:NO];
	
}


#pragma mark -
#pragma mark Action Methods

- (void)doneSavingImage{
	NSLog(@"done saving image");
}

- (void)savePhoto{
	UIImageWriteToSavedPhotosAlbum(((EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).imageView.image, nil, nil, nil);
}

- (void)copyPhoto{
	[[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation(((EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).imageView.image) forPasteboardType:@"public.png"];
}

- (void)emailPhoto{
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject:@"Shared Photo"];
	[mailViewController addAttachmentData:[NSData dataWithData:UIImagePNGRepresentation(((EGOPhotoImageView*)[self.photoViews objectAtIndex:_pageIndex]).imageView.image)] mimeType:@"png" fileName:@"Photo.png"];
	mailViewController.mailComposeDelegate = self;
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
	[self dismissModalViewControllerAnimated:YES];
	
	NSString *mailError = nil;
	
	switch (result) {
		case MFMailComposeResultSent: ; break;
		case MFMailComposeResultFailed: mailError = @"Failed sending media, please try again...";
			break;
		default:
			break;
	}
	
	if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

}


#pragma mark -
#pragma mark ActionSheet Delegate Methods

- (void)actionButtonHit:(id)sender{

	UIActionSheet *actionSheet;
	if ([MFMailComposeViewController canSendMail]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Copy", @"Email", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Copy", nil];
	}
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[actionSheet showFromBarButtonItem:(UIBarButtonItem*)sender animated:YES];
	} else {
		[actionSheet showInView:self.view];
		[self setBarsHidden:YES animated:YES];
	}
#else
	[actionSheet showInView:self.view];	
	[self setBarsHidden:YES animated:YES];
#endif
	
	[actionSheet release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	[self setBarsHidden:NO animated:YES];
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		[self savePhoto];
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
		[self copyPhoto];	
	} else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
		[self emailPhoto];	
	}
}


#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload{
	[super viewDidUnload];
	_scrollView=nil;
}

- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_photoViews release], _photoViews=nil;
	[_photoSource release], _photoSource=nil;
	[_captionView release], _captionView=nil;
	[_scrollView release], _scrollView=nil;
	[_oldToolBarTintColor release], _oldToolBarTintColor = nil;
	[_oldNavBarTintColor release], _oldNavBarTintColor = nil;
	
    [super dealloc];
}


@end
