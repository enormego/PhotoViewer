#import "PVPhotoView.h"
#import "PVImageView.h"
#import "PVLabel.h"
#import "PVURLCache.h"
#import "PVURLRequestQueue.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PVPhotoView
@synthesize photo = _photo, hidesExtras = _hidesExtras, hidesCaption = _hidesCaption;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (BOOL)loadVersion:(PVPhotoVersion)version fromNetwork:(BOOL)fromNetwork {
	NSString* URL = [_photo URLForVersion:version];
	if (URL) {
		UIImage* image = [[PVURLCache sharedCache] imageForURL:URL];
		if (image || fromNetwork) {
			_photoVersion = version;
			self.URL = URL;
			return YES;
		}
	}
	return NO;
}

- (void)showCaption:(NSString*)caption {
	if (caption) {
		if (!_captionLabel) {
			_captionLabel = [[PVLabel alloc] init];
			_captionLabel.contentInset = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
			_captionLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.50f];
			_captionLabel.textColor = [UIColor whiteColor];
			_captionLabel.shadowColor = [UIColor blackColor];
			_captionLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
			_captionLabel.lineBreakMode = UILineBreakModeWordWrap;
			_captionLabel.textAlignment = UITextAlignmentCenter;
			_captionLabel.opaque = NO;
			_captionLabel.alpha = _hidesCaption ? 0.0f : 1.0f;
			[self addSubview:_captionLabel];
		}
	}
	
	_captionLabel.text = caption;
	[self setNeedsLayout];
}

#pragma mark -
#pragma mark NSObject

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_photo = nil;
		_statusSpinner = nil;
		_statusLabel = nil;
		_captionLabel = nil;
		_photoVersion = PVPhotoVersionNone;
		_hidesExtras = NO;
		_hidesCaption = NO;
		
		self.clipsToBounds = NO;
	}
	return self;
}

- (void)dealloc {
	[[PVURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
	[super setDelegate:nil];
	PV_RELEASE_SAFELY(_photo);
	PV_RELEASE_SAFELY(_captionLabel);
	PV_RELEASE_SAFELY(_statusSpinner);
	PV_RELEASE_SAFELY(_statusLabel);
	[super dealloc];
}

#pragma mark -
#pragma mark PVImageView

- (void)setImage:(UIImage*)image {
	if (image != _defaultImage || !_photo || self.URL != [_photo URLForVersion:PVPhotoVersionLarge]) {
		if (image == _defaultImage) {
			self.contentMode = UIViewContentModeCenter;
		} else {
			self.contentMode = UIViewContentModeScaleAspectFill;
		}
		
		[super setImage:image];
	}
}

- (void)imageViewDidStartLoad {
	[self showProgress:0];
}

- (void)imageViewDidLoadImage:(UIImage*)image {
	if (!_photo.photoSource.isLoading) {
		[self showProgress:-1];
		[self showStatus:nil];
	}
	
	if (!_photo.size.width) {
		_photo.size = image.size;
		[self.superview setNeedsLayout];
	}
}

- (void)imageViewDidFailLoadWithError:(NSError*)error {
	[self showProgress:0];
	
	if (error) {
		[self showStatus:PVDescriptionForError(error)];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
	CGRect screenBounds = PVScreenBounds();
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
	CGFloat cx = self.bounds.origin.x + width/2;
	CGFloat cy = self.bounds.origin.y + height/2;
	CGFloat marginRight = 0, marginLeft = 0, marginBottom = PVToolbarHeight();
	
	// Since the photo view is constrained to the size of the image, but we want to position
	// the status views relative to the screen, offset by the difference
	CGFloat screenOffset = -floor(screenBounds.size.height/2 - height/2);
	
	// Vertically center in the space between the bottom of the image and the bottom of the screen
	CGFloat imageBottom = screenBounds.size.height/2 + self.defaultImage.size.height/2;
	CGFloat textWidth = screenBounds.size.width - (marginLeft+marginRight);
	
	if (_statusLabel.text.length) {
		CGSize statusSize = [_statusLabel sizeThatFits:CGSizeMake(textWidth, 0)];
		_statusLabel.frame = 
        CGRectMake(marginLeft + (cx - screenBounds.size.width/2), 
                   cy + floor(screenBounds.size.height/2 - (statusSize.height+marginBottom)),
                   textWidth, statusSize.height);
	} else {
		_statusLabel.frame = CGRectZero;
	}
	
	if (_captionLabel.text.length) {
		CGSize captionSize = [_captionLabel sizeThatFits:CGSizeMake(textWidth, 0)];
		_captionLabel.frame = CGRectMake(marginLeft + (cx - screenBounds.size.width/2), 
										 cy + floor(screenBounds.size.height/2
													- (captionSize.height+marginBottom)),
										 textWidth, captionSize.height);
	} else {
		_captionLabel.frame = CGRectZero;
	}
	
	CGFloat spinnerTop = _captionLabel.frame.size.height
    ? _captionLabel.frame.origin.y - floor(_statusSpinner.frame.size.height + _statusSpinner.frame.size.height/2)
    : screenOffset + imageBottom + floor(_statusSpinner.frame.size.height/2);
	
	
	_statusSpinner.frame =
    CGRectMake(self.bounds.origin.x + floor(self.bounds.size.width/2 - _statusSpinner.frame.size.width/2), 350.0f, _statusSpinner.frame.size.width, _statusSpinner.frame.size.height);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPhoto:(id<PVPhoto>)photo {
	if (!photo || photo != _photo) {
		[_photo release];
		_photo = [photo retain];
		_photoVersion = PVPhotoVersionNone;
		
		self.URL = nil;
		
		[self showCaption:photo.caption];
	}
	
	if (!_photo || _photo.photoSource.isLoading) {
		[self showProgress:0];
	} else {
		[self showStatus:nil];
	}
}

- (void)setHidesExtras:(BOOL)hidesExtras {
	if (!hidesExtras) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:PV_FAST_TRANSITION_DURATION];
	}
	_hidesExtras = hidesExtras;
	_statusSpinner.alpha = _hidesExtras ? 0 : 1;
	_statusLabel.alpha = _hidesExtras ? 0 : 1;
	_captionLabel.alpha = _hidesExtras || _hidesCaption ? 0 : 1;
	if (!hidesExtras) {
		[UIView commitAnimations];
	}
}

- (void)setHidesCaption:(BOOL)hidesCaption {
	_hidesCaption = hidesCaption;
	_captionLabel.alpha = hidesCaption ? 0 : 1;
}

- (BOOL)loadPreview:(BOOL)fromNetwork {
	if (![self loadVersion:PVPhotoVersionLarge fromNetwork:NO]) {
		if (![self loadVersion:PVPhotoVersionSmall fromNetwork:YES]) {
			if (![self loadVersion:PVPhotoVersionThumbnail fromNetwork:fromNetwork]) {
				return NO;
			}
		}
	}
	
	return YES;
}

- (void)loadImage {
	if (_photo) {
		_photoVersion = PVPhotoVersionLarge;
		self.URL = [_photo URLForVersion:PVPhotoVersionLarge];
	}
}

- (void)showProgress:(CGFloat)progress {
	if (progress >= 0) {
		if (!_statusSpinner) {
			_statusSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
							  UIActivityIndicatorViewStyleWhiteLarge];
			[self addSubview:_statusSpinner];
		}
		
		[_statusSpinner startAnimating];
		_statusSpinner.hidden = NO;
		[self showStatus:nil];
		[self setNeedsLayout];
	} else {
		[_statusSpinner stopAnimating];
		_statusSpinner.hidden = YES;
		_captionLabel.hidden = !!_statusLabel.text.length;
	}
}

- (void)showStatus:(NSString*)text {
	if (text) {
		if (!_statusLabel) {
			_statusLabel = [[PVLabel alloc] init];
			_statusLabel.opaque = NO;
			[self addSubview:_statusLabel];
		}
		_statusLabel.hidden = NO;
		[self showProgress:-1];
		[self setNeedsLayout];
		_captionLabel.hidden = YES;
	} else {
		_statusLabel.hidden = YES;
		_captionLabel.hidden = NO;
	}
	
	_statusLabel.text = text;
}

@end
