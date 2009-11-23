#import "TTPhotoViewController.h"
#import "TTURLRequestQueue.h"
#import "TTURLCache.h"
#import "TTURLRequest.h"
#import "TTPhotoView.h"
#import "TTLabel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static const NSTimeInterval kPhotoLoadLongDelay = 0.5;
static const NSTimeInterval kPhotoLoadShortDelay = 0.25;
static const NSTimeInterval kSlideshowInterval = 2;
static const NSInteger kActivityLabelTag = 96;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTPhotoViewController

@synthesize photoSource = _photoSource, centerPhoto = _centerPhoto,
	centerPhotoIndex = _centerPhotoIndex, defaultImage = _defaultImage, isViewAppearing = _isViewAppearing, hasViewAppeared = _hasViewAppeared,
	model = _model, modelError = _modelError;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (TTPhotoView*)centerPhotoView {
  return (TTPhotoView*)_scrollView.centerPage;
}

- (void)loadImageDelayed {
  _loadTimer = nil;
  [self.centerPhotoView loadImage];
}

- (void)startImageLoadTimer:(NSTimeInterval)delay {
  [_loadTimer invalidate];
  _loadTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self
    selector:@selector(loadImageDelayed) userInfo:nil repeats:NO];
}

- (void)cancelImageLoadTimer {
  [_loadTimer invalidate];
  _loadTimer = nil;
}

- (void)loadImages {
  TTPhotoView* centerPhotoView = self.centerPhotoView;
  for (TTPhotoView* photoView in _scrollView.visiblePages.objectEnumerator) {
    if (photoView == centerPhotoView) {
      [photoView loadPreview:NO];
    } else {
      [photoView loadPreview:YES];
    }
  }

  if (_delayLoad) {
    _delayLoad = NO;
    [self startImageLoadTimer:kPhotoLoadLongDelay];
  } else {
    [centerPhotoView loadImage];
  }
}

- (void)updateChrome {
  if (_photoSource.numberOfPhotos < 2) {
    self.title = _photoSource.title;
  } else {
    self.title = [NSString stringWithFormat: TTLocalizedString(@"%d of %d", @"Current page in photo browser (1 of 10)"), _centerPhotoIndex+1, _photoSource.numberOfPhotos];
  }

  /*if (![self.previousViewController isKindOfClass:[TTThumbsViewController class]]) {
    if (_photoSource.numberOfPhotos > 1) {
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:TTLocalizedString(@"See All", @"See all photo thumbnails")
        style:UIBarButtonItemStyleBordered target:self action:@selector(showThumbnails)];
    } else {
      self.navigationItem.rightBarButtonItem = nil;
    }
  } else {*/
    self.navigationItem.rightBarButtonItem = nil;
  //}

  UIBarButtonItem* playButton = [_toolbar itemWithTag:1];
  playButton.enabled = _photoSource.numberOfPhotos > 1;
  _previousButton.enabled = _centerPhotoIndex > 0;
  _nextButton.enabled = _centerPhotoIndex >= 0 && _centerPhotoIndex < _photoSource.numberOfPhotos-1;
}

- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
	CGRect toolbarRect = _toolbar.frame;
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		toolbarRect.size.height = TT_TOOLBAR_HEIGHT;
	} else {
		toolbarRect.size.height = TT_LANDSCAPE_TOOLBAR_HEIGHT+1;
	}
	
	toolbarRect.origin.y = self.view.frame.size.height - toolbarRect.size.height;
	
	_toolbar.frame = toolbarRect;
}

- (void)updatePhotoView {
  _scrollView.centerPageIndex = _centerPhotoIndex;
  [self loadImages];
  [self updateChrome];
}

- (void)moveToPhoto:(id<TTPhoto>)photo {
  id<TTPhoto> previousPhoto = [_centerPhoto autorelease];
  _centerPhoto = [photo retain];
  [self didMoveToPhoto:_centerPhoto fromPhoto:previousPhoto];
}

- (void)moveToPhotoAtIndex:(NSInteger)photoIndex withDelay:(BOOL)withDelay {
  _centerPhotoIndex = photoIndex == TT_NULL_PHOTO_INDEX ? 0 : photoIndex;
  [self moveToPhoto:[_photoSource photoAtIndex:_centerPhotoIndex]];
  _delayLoad = withDelay;
}

- (void)showPhoto:(id<TTPhoto>)photo inView:(TTPhotoView*)photoView {
  photoView.photo = photo;
  if (!photoView.photo && _statusText) {
    [photoView showStatus:_statusText];
  }
}

- (void)updateVisiblePhotoViews {
  [self moveToPhoto:[_photoSource photoAtIndex:_centerPhotoIndex]];

  NSDictionary* photoViews = _scrollView.visiblePages;
  for (NSNumber* key in photoViews.keyEnumerator) {
    TTPhotoView* photoView = [photoViews objectForKey:key];
    [photoView showProgress:-1];

    id<TTPhoto> photo = [_photoSource photoAtIndex:key.intValue];
    [self showPhoto:photo inView:photoView];
  }
}

- (void)resetVisiblePhotoViews {
  NSDictionary* photoViews = _scrollView.visiblePages;
  for (TTPhotoView* photoView in photoViews.objectEnumerator) {
    if (!photoView.isLoading) {
      [photoView showProgress:-1];
    }
  }
}

- (BOOL)isShowingChrome {
  UINavigationBar* bar = self.navigationController.navigationBar;
  return bar ? bar.alpha != 0 : 1;
}

- (TTPhotoView*)statusView {
  if (!_photoStatusView) {
    _photoStatusView = [[TTPhotoView alloc] initWithFrame:_scrollView.frame];
    _photoStatusView.defaultImage = _defaultImage;
    _photoStatusView.photo = nil;
    [_innerView addSubview:_photoStatusView];
  }
  
  return _photoStatusView;
}

- (void)showProgress:(CGFloat)progress {
  if ((self.hasViewAppeared || self.isViewAppearing) && progress >= 0 && !self.centerPhotoView) {
    [self.statusView showProgress:progress];
    self.statusView.hidden = NO;
  } else {
    _photoStatusView.hidden = YES;
  }
}

- (void)showStatus:(NSString*)status {
  [_statusText release];
  _statusText = [status retain];

  if ((self.hasViewAppeared || self.isViewAppearing) && status && !self.centerPhotoView) {
    [self.statusView showStatus:status];
    self.statusView.hidden = NO;
  } else {
    _photoStatusView.hidden = YES;
  }
}

- (void)showCaptions:(BOOL)show {
  for (TTPhotoView* photoView in _scrollView.visiblePages.objectEnumerator) {
    photoView.hidesCaption = !show;
  }
}

- (NSString*)URLForThumbnails {
  if ([self.photoSource respondsToSelector:@selector(URLValueWithName:)]) {
    return [self.photoSource performSelector:@selector(URLValueWithName:)
                             withObject:@"TTThumbsViewController"];
  } else {
    return nil;
  }
}

- (void)showThumbnails {
	if (!_thumbsController) {
		_thumbsController = [[self createThumbsViewController] retain];
	}
    
    [self presentModalViewController:_thumbsController animated:YES];
}

- (void)slideshowTimer {
  if (_centerPhotoIndex == _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = 0;
  } else {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}

- (void)playAction {
  if (!_slideshowTimer) {
    UIBarButtonItem* pauseButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
      UIBarButtonSystemItemPause target:self action:@selector(pauseAction)] autorelease];
    pauseButton.tag = 1;
    
    [_toolbar replaceItemWithTag:1 withItem:pauseButton];

    _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:kSlideshowInterval
      target:self selector:@selector(slideshowTimer) userInfo:nil repeats:YES];
  }
}

- (void)pauseAction {
  if (_slideshowTimer) {
    UIBarButtonItem* playButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
      UIBarButtonSystemItemPlay target:self action:@selector(playAction)] autorelease];
    playButton.tag = 1;
    
    [_toolbar replaceItemWithTag:1 withItem:playButton];

    [_slideshowTimer invalidate];
    _slideshowTimer = nil;
  }
}

- (void)nextAction {
  [self pauseAction];
  if (_centerPhotoIndex < _photoSource.numberOfPhotos-1) {
    _scrollView.centerPageIndex = _centerPhotoIndex+1;
  }
}

- (void)previousAction {
  [self pauseAction];
  if (_centerPhotoIndex > 0) {
    _scrollView.centerPageIndex = _centerPhotoIndex-1;
  }
}

- (void)showBarsAnimationDidStop {
  self.navigationController.navigationBarHidden = NO;
}

- (void)hideBarsAnimationDidStop {
  self.navigationController.navigationBarHidden = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithPhoto:(id<TTPhoto>)photo {
  if (self = [self init]) {
    self.centerPhoto = photo;
  }
  return self;
}

- (id)initWithPhotoSource:(id<TTPhotoSource>)photoSource {
  if (self = [self init]) {
    self.photoSource = photoSource;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
	  _model = nil;
	  _modelError = nil;
	  _flags.isModelDidRefreshInvalid = NO;
	  _flags.isModelWillLoadInvalid = NO;
	  _flags.isModelDidLoadInvalid = NO;
	  _flags.isModelDidLoadFirstTimeInvalid = NO;
	  _flags.isModelDidShowFirstTimeInvalid = NO;
	  _flags.isViewInvalid = YES;
	  _flags.isViewSuspended = NO;
	  _flags.isUpdatingView = NO;
	  _flags.isShowingEmpty = NO;
	  _flags.isShowingLoading = NO;
	  _flags.isShowingModel = NO;
	  _flags.isShowingError = NO;
	  
    _photoSource = nil;
    _centerPhoto = nil;
    _centerPhotoIndex = 0;
    _scrollView = nil;
    _photoStatusView = nil;
    _toolbar = nil;
    _defaultImage = nil;
    _nextButton = nil;
    _previousButton = nil;
    _statusText = nil;
    _thumbsController = nil;
    _slideshowTimer = nil;
    _loadTimer = nil;
    _delayLoad = NO;
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:
      TTLocalizedString(@"Photo", @"Title for back button that returns to photo browser")
      style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

    self.wantsFullScreenLayout = YES;
    self.hidesBottomBarWhenPushed = YES;

	  self.defaultImage = [UIImage imageNamed:@"pv_img_photoDefault.png"];
  }
  return self;
}

- (void)dealloc {
  // _thumbsController.delegate = nil;
  TT_INVALIDATE_TIMER(_slideshowTimer);
  TT_INVALIDATE_TIMER(_loadTimer);
  TT_RELEASE_SAFELY(_thumbsController);
  TT_RELEASE_SAFELY(_centerPhoto);
  TT_RELEASE_SAFELY(_photoSource);
  TT_RELEASE_SAFELY(_statusText);
  TT_RELEASE_SAFELY(_defaultImage);
	
	[_model.delegates removeObject:self];
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_modelError);
	
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  CGRect screenFrame = [UIScreen mainScreen].bounds;
  self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
    
  CGRect innerFrame = CGRectMake(0, 0,
                                 screenFrame.size.width, screenFrame.size.height);
  _innerView = [[UIView alloc] initWithFrame:innerFrame];
  _innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_innerView];
  
  _scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
  _scrollView.delegate = self;
  _scrollView.dataSource = self;
  _scrollView.backgroundColor = [UIColor blackColor];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  [_innerView addSubview:_scrollView];
  
  _nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pv_img_nextIcon.png"];
     style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
  _previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pv_img_previousIcon.png"];
     style:UIBarButtonItemStylePlain target:self action:@selector(previousAction)];

  UIBarButtonItem* playButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
    UIBarButtonSystemItemPlay target:self action:@selector(playAction)] autorelease];
  playButton.tag = 1;

  UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
   UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  _toolbar = [[UIToolbar alloc] initWithFrame:
    CGRectMake(0, screenFrame.size.height - TT_ROW_HEIGHT,
               screenFrame.size.width, TT_ROW_HEIGHT)];
  _toolbar.barStyle = self.navigationController.navigationBar.barStyle;
  _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
  _toolbar.items = [NSArray arrayWithObjects:
                   space, _previousButton, space, _nextButton, space, nil];
  [_innerView addSubview:_toolbar];    
}

- (void)viewDidUnload {
  [super viewDidUnload];
  _scrollView.delegate = nil;
  _scrollView.dataSource = nil;
  TT_RELEASE_SAFELY(_innerView);
  TT_RELEASE_SAFELY(_scrollView);
  TT_RELEASE_SAFELY(_photoStatusView);
  TT_RELEASE_SAFELY(_nextButton);
  TT_RELEASE_SAFELY(_previousButton);
  TT_RELEASE_SAFELY(_toolbar);
}

- (void)viewWillAppear:(BOOL)animated {
	_isViewAppearing = YES;
	_hasViewAppeared = YES;
	
	[self updateView];
	
	[super viewWillAppear:animated];

	[TTURLRequestQueue mainQueue].suspended = YES;
	
	[self updateToolbarWithOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[TTURLRequestQueue mainQueue].suspended = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
	_isViewAppearing = NO;

  [_scrollView cancelTouches];
  [self pauseAction];
  // if (self.nextViewController) {
    [self showBars:YES animated:NO];
  // }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
        duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self updateToolbarWithOrientation:toInterfaceOrientation];
}

- (UIView *)rotatingFooterView {
  return _toolbar;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [super showBars:show animated:animated];

  CGFloat alpha = show ? 1 : 0;
  if (alpha == _toolbar.alpha)
    return;
  
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    if (show) {
      [UIView setAnimationDidStopSelector:@selector(showBarsAnimationDidStop)];
    } else {
      [UIView setAnimationDidStopSelector:@selector(hideBarsAnimationDidStop)];
    }
  } else {
    if (show) {
      [self showBarsAnimationDidStop];
    } else {
      [self hideBarsAnimationDidStop];
    }
  }

  [self showCaptions:show];
  
  _toolbar.alpha = alpha;
  
  if (animated) {
    [UIView commitAnimations];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (BOOL)shouldLoad {
  return NO;
}

- (BOOL)shouldLoadMore {
  return !_centerPhoto;
}

- (BOOL)canShowModel {
  return _photoSource.numberOfPhotos > 0;
}

- (void)didRefreshModel {
  [self updatePhotoView];
}

- (void)didLoadModel:(BOOL)firstTime {
  if (firstTime) {
    [self updatePhotoView];
  }
}

- (void)showLoading:(BOOL)show {
  [self showProgress:show ? 0 : -1];
}

- (void)showEmpty:(BOOL)show {
  if (show) {
    [_scrollView reloadData];
    [self showStatus:TTLocalizedString(@"This photo set contains no photos.", @"")];
  } else {
    [self showStatus:nil];
  }
}

- (void)showError:(BOOL)show {
  if (show) {
    [self showStatus:TTDescriptionForError(_modelError)];
  } else {
    [self showStatus:nil];
  }
}

- (void)moveToNextValidPhoto {
  if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
    // We were positioned at an index that is past the end, so move to the last photo
    [self moveToPhotoAtIndex:_photoSource.numberOfPhotos - 1 withDelay:NO];
  } else {
    [self moveToPhotoAtIndex:_centerPhotoIndex withDelay:NO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidFinishLoad:(id<TTModel>)model {
  if (model == _model) {
    if (_centerPhotoIndex >= _photoSource.numberOfPhotos) {
      [self moveToNextValidPhoto];
      [_scrollView reloadData];
      [self resetVisiblePhotoViews];
    } else {
      [self updateVisiblePhotoViews];
    }
  }
	
	if (model == _model) {
		TT_RELEASE_SAFELY(_modelError);
		_flags.isModelDidLoadInvalid = YES;
		[self invalidateView];
	}
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    [self resetVisiblePhotoViews];
	  self.modelError = error;
  }
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
  if (model == _model) {
    [self resetVisiblePhotoViews];
	  [self invalidateView];
  }
}

- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  if (object == self.centerPhoto) {
    [self showActivity:nil];
    [self moveToNextValidPhoto];
    [_scrollView reloadData];
    [self refresh];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTScrollViewDelegate

- (void)scrollView:(TTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex {
  if (pageIndex != _centerPhotoIndex) {
    [self moveToPhotoAtIndex:pageIndex withDelay:YES];
    [self refresh];
  }
}

- (void)scrollViewWillBeginDragging:(TTScrollView *)scrollView {
  [self cancelImageLoadTimer];
  [self showCaptions:NO];
  [self showBars:NO animated:YES];
}

- (void)scrollViewDidEndDecelerating:(TTScrollView*)scrollView {
  [self startImageLoadTimer:kPhotoLoadShortDelay];
}

- (void)scrollViewWillRotate:(TTScrollView*)scrollView
        toOrientation:(UIInterfaceOrientation)orientation {
  self.centerPhotoView.hidesExtras = YES;
}

- (void)scrollViewDidRotate:(TTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = NO;
}

- (BOOL)scrollViewShouldZoom:(TTScrollView*)scrollView {
  return self.centerPhotoView.image != self.centerPhotoView.defaultImage;
}

- (void)scrollViewDidBeginZooming:(TTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = YES;
}

- (void)scrollViewDidEndZooming:(TTScrollView*)scrollView {
  self.centerPhotoView.hidesExtras = NO;
}

- (void)scrollView:(TTScrollView*)scrollView tapped:(UITouch*)touch {
  if ([self isShowingChrome]) {
    [self showBars:NO animated:YES];
  } else {
    [self showBars:YES animated:NO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTScrollViewDataSource

- (NSInteger)numberOfPagesInScrollView:(TTScrollView*)scrollView {
  return _photoSource.numberOfPhotos;
}

- (UIView*)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
  TTPhotoView* photoView = (TTPhotoView*)[_scrollView dequeueReusablePage];
  if (!photoView) {
    photoView = [self createPhotoView];
    photoView.defaultImage = _defaultImage;
    photoView.hidesCaption = _toolbar.alpha == 0;
  }

  id<TTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  [self showPhoto:photo inView:photoView];
  
  return photoView;
}

- (CGSize)scrollView:(TTScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)pageIndex {
  id<TTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
  return photo ? photo.size : CGSizeZero;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTThumbsViewControllerDelegate

- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo {
  self.centerPhoto = photo;
	[controller dismissModalViewControllerAnimated:YES];
}

- (BOOL)thumbsViewController:(TTThumbsViewController*)controller
        shouldNavigateToPhoto:(id<TTPhoto>)photo {
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
  if (_photoSource != photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];
    
    [self moveToPhotoAtIndex:0 withDelay:NO];
    self.model = _photoSource;
  }
}

- (void)setCenterPhoto:(id<TTPhoto>)photo {
  if (_centerPhoto != photo) {
    if (photo.photoSource != _photoSource) {
      [_photoSource release];
      _photoSource = [photo.photoSource retain];

      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      self.model = _photoSource;
    } else {
      [self moveToPhotoAtIndex:photo.index withDelay:NO];
      [self refresh];
    }
  }
}

- (TTPhotoView*)createPhotoView {
  return [[[TTPhotoView alloc] init] autorelease];
}

- (TTThumbsViewController*)createThumbsViewController {
  return [[[TTThumbsViewController alloc] init/*WithDelegate:self*/] autorelease];
}

- (void)didMoveToPhoto:(id<TTPhoto>)photo fromPhoto:(id<TTPhoto>)fromPhoto {
}

- (void)showActivity:(NSString*)title {
  if (title) {
    TTLabel* label = [[[TTLabel alloc] init] autorelease];
    label.tag = kActivityLabelTag;
    label.text = title;
    label.frame = _scrollView.frame;
    [_innerView addSubview:label];

    _scrollView.scrollEnabled = NO;
  } else {
    UIView* label = [_innerView viewWithTag:kActivityLabelTag];
    if (label) {
      [label removeFromSuperview];
    }

    _scrollView.scrollEnabled = YES;
  }
}

// Model View Controller
- (void)resetViewStates {
	if (_flags.isShowingLoading) {
		[self showLoading:NO];
		_flags.isShowingLoading = NO;
	}
	if (_flags.isShowingModel) {
		[self showModel:NO];
		_flags.isShowingModel = NO;
	}
	if (_flags.isShowingError) {
		[self showError:NO];
		_flags.isShowingError = NO;
	}
	if (_flags.isShowingEmpty) {
		[self showEmpty:NO];
		_flags.isShowingEmpty = NO;
	}
}

- (void)updateViewStates {
	if (_flags.isModelDidRefreshInvalid) {
		[self didRefreshModel];
		_flags.isModelDidRefreshInvalid = NO;
	}
	if (_flags.isModelWillLoadInvalid) {
		[self willLoadModel];
		_flags.isModelWillLoadInvalid = NO;
	}
	if (_flags.isModelDidLoadInvalid) {
		[self didLoadModel:_flags.isModelDidLoadFirstTimeInvalid];
		_flags.isModelDidLoadInvalid = NO;
		_flags.isModelDidLoadFirstTimeInvalid = NO;
		_flags.isShowingModel = NO;
	}
	
	BOOL showModel = NO, showLoading = NO, showError = NO, showEmpty = NO;
	
	if (_model.isLoaded || ![self shouldLoad]) {
		if ([self canShowModel]) {
			showModel = !_flags.isShowingModel;
			_flags.isShowingModel = YES;
		} else {
			if (_flags.isShowingModel) {
				[self showModel:NO];
				_flags.isShowingModel = NO;
			}
		}
	} else {
		if (_flags.isShowingModel) {
			[self showModel:NO];
			_flags.isShowingModel = NO;
		}
	}
	
	if (_model.isLoading) {
		showLoading = !_flags.isShowingLoading;
		_flags.isShowingLoading = YES;
	} else {
		if (_flags.isShowingLoading) {
			[self showLoading:NO];
			_flags.isShowingLoading = NO;
		}
	}
	
	if (_modelError) {
		showError = !_flags.isShowingError;
		_flags.isShowingError = YES;
	} else {
		if (_flags.isShowingError) {
			[self showError:NO];
			_flags.isShowingError = NO;
		}
	}
	
	if (!_flags.isShowingLoading && !_flags.isShowingModel && !_flags.isShowingError) {
		showEmpty = !_flags.isShowingEmpty;
		_flags.isShowingEmpty = YES;
	} else {
		if (_flags.isShowingEmpty) {
			[self showEmpty:NO];
			_flags.isShowingEmpty = NO;
		}
	}
	
	if (showModel) {
		[self showModel:YES];
		[self didShowModel:_flags.isModelDidShowFirstTimeInvalid];
		_flags.isModelDidShowFirstTimeInvalid = NO;
	}
	if (showEmpty) {
		[self showEmpty:YES];
	}
	if (showError) {
		[self showError:YES];
	}
	if (showLoading) {
		[self showLoading:YES];
	}
}

- (void)createInterstitialModel {
	self.model = [[[TTModel alloc] init] autorelease];
}

- (void)delayDidEnd {
	[self invalidateModel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidStartLoad:(id<TTModel>)model {
	if (model == self.model) {
		_flags.isModelWillLoadInvalid = YES;
		_flags.isModelDidLoadFirstTimeInvalid = YES;
		[self invalidateView];
	}
}

- (void)modelDidChange:(id<TTModel>)model {
	if (model == _model) {
		[self refresh];
	}
}

- (void)modelDidBeginUpdates:(id<TTModel>)model {
	if (model == _model) {
		[self beginUpdates];
	}
}

- (void)modelDidEndUpdates:(id<TTModel>)model {
	if (model == _model) {
		[self endUpdates];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id<TTModel>)model {
	if (!_model) {
		if (!_model) {
			[self createInterstitialModel];
		}
	}
	return _model;
}

- (void)setModel:(id<TTModel>)model {
	if (_model != model) {
		[_model.delegates removeObject:self];
		[_model release];
		_model = [model retain];
		[_model.delegates addObject:self];
		TT_RELEASE_SAFELY(_modelError);
		
		if (_model) {
			_flags.isModelWillLoadInvalid = NO;
			_flags.isModelDidLoadInvalid = NO;
			_flags.isModelDidLoadFirstTimeInvalid = NO;
			_flags.isModelDidShowFirstTimeInvalid = YES;
		}
		
		[self refresh];
	}
}

- (void)setModelError:(NSError*)error {
	if (error != _modelError) {
		[_modelError release];
		_modelError = [error retain];
		
		[self invalidateView];
	}
}

- (void)createModel {
}

- (void)invalidateModel {
	BOOL wasModelCreated = self.isModelCreated;
	[self resetViewStates];
	[_model.delegates removeObject:self];
	TT_RELEASE_SAFELY(_model);
	if (wasModelCreated) {
		self.model;
	}
}

- (BOOL)isModelCreated {
	return !!_model;
}

- (BOOL)shouldReload {
	return !_modelError && self.model.isOutdated;
}

- (void)reload {
	_flags.isViewInvalid = YES;
	[self.model load:TTURLRequestCachePolicyNetwork more:NO];
}

- (void)reloadIfNeeded {
	if ([self shouldReload] && !self.model.isLoading) {
		[self reload];
	}
}

- (void)refresh {
	_flags.isViewInvalid = YES;
	_flags.isModelDidRefreshInvalid = YES;
	
	BOOL loading = self.model.isLoading;
	BOOL loaded = self.model.isLoaded;
	if (!loading && !loaded && [self shouldLoad]) {
		[self.model load:TTURLRequestCachePolicyDefault more:NO];
	} else if (!loading && loaded && [self shouldReload]) {
		[self.model load:TTURLRequestCachePolicyNetwork more:NO];
	} else if (!loading && [self shouldLoadMore]) {
		[self.model load:TTURLRequestCachePolicyDefault more:YES];
	} else {
		_flags.isModelDidLoadInvalid = YES;
		if (_isViewAppearing) {
			[self updateView];
		}
	}
}

- (void)beginUpdates {
	_flags.isViewSuspended = YES;
}

- (void)endUpdates {
	_flags.isViewSuspended = NO;
	[self updateView];
}

- (void)invalidateView {
	_flags.isViewInvalid = YES;
	if (_isViewAppearing) {
		[self updateView];
	}
}

- (void)updateView {
	if (_flags.isViewInvalid && !_flags.isViewSuspended && !_flags.isUpdatingView) {
		_flags.isUpdatingView = YES;
		
		// Ensure the model is created
		self.model;
		// Ensure the view is created
		self.view;
		
		[self updateViewStates];
	}
}

- (void)willLoadModel {
}

- (void)didShowModel:(BOOL)firstTime {
}

- (void)showModel:(BOOL)show {
}

@end
