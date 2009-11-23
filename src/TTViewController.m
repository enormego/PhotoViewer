#import "PhotoViewer/TTViewController.h"
#import "PhotoViewer/TTURLRequestQueue.h"
#import "PhotoViewer/TTStyleSheet.h"
#import "PhotoViewer/TTNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTViewController
@synthesize isViewAppearing = _isViewAppearing, hasViewAppeared = _hasViewAppeared;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_isViewAppearing = YES;
	_hasViewAppeared = YES;
	
	[TTURLRequestQueue mainQueue].suspended = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	_isViewAppearing = NO;
}

@end
