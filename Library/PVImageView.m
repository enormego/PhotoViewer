#import "PVImageView.h"
#import "PVURLCache.h"
#import "PVURLResponse.h"
#import "QuartzCore/CALayer.h"

@interface PVImageLayer : CALayer {
	PVImageView* _override;
}

@property(nonatomic,assign) PVImageView* override;
@end

@implementation PVImageLayer
@synthesize override=_override;

- (id)init {
	if(self = [super init]) {
		_override = NO;
	}
	return self;
}

- (void)display {
	if(_override) {
		self.contents = (id)_override.image.CGImage;
	} else {
		return [super display];
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

#pragma mark -

@interface PVImageView ()
- (void)updateLayer;
@end


@implementation PVImageView
@synthesize delegate=_delegate, URL=_URL, image=_image, defaultImage=_defaultImage, autoresizesToImage=_autoresizesToImage;

- (id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame]) {
		_delegate = nil;
		_request = nil;
		_URL = nil;
		_image = nil;
		_defaultImage = nil;
		_autoresizesToImage = NO;
	}
	return self;
}

#pragma mark -
#pragma mark PVURLRequest methods

- (void)requestDidStartLoad:(PVURLRequest*)request {
	[_request release];
	_request = [request retain];
	
	[self imageViewDidStartLoad];
	
	if([_delegate respondsToSelector:@selector(imageViewDidStartLoad:)]) {
		[_delegate imageViewDidStartLoad:self];
	}
}

- (void)requestDidFinishLoad:(PVURLRequest*)request {
	PVURLImageResponse* response = request.response;
	self.image = response.image;
	
	PV_RELEASE_SAFELY(_request);
}

- (void)request:(PVURLRequest*)request didFailLoadWithError:(NSError*)error {
	PV_RELEASE_SAFELY(_request);
	
	[self imageViewDidFailLoadWithError:error];
	
	if([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
		[_delegate imageView:self didFailLoadWithError:error];
	}
}

- (void)requestDidCancelLoad:(PVURLRequest*)request {
	PV_RELEASE_SAFELY(_request);
	
	[self imageViewDidFailLoadWithError:nil];
	
	if([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
		[_delegate imageView:self didFailLoadWithError:nil];
	}
}

#pragma mark -
#pragma mark Image/URL Methods

- (void)setURL:(NSString*)URL {
	if(self.image && _URL && [URL isEqualToString:_URL]) {
		return;
	}
	
	[self stopLoading];
	
	[_URL release];
	_URL = [URL retain];
	
	if(!_URL || !_URL.length) {
		if(self.image != _defaultImage) {
			self.image = _defaultImage;
		}
	} else {
		[self reload];
	}
}

- (void)setImage:(UIImage*)image {
	if(image == _image) return;
	
	[_image release];
	_image = [image retain];
	
	[self updateLayer];
	
	CGRect frame = self.frame;
	
	if(_autoresizesToImage) {
		self.frame = CGRectMake(frame.origin.x, frame.origin.y, image.size.width, image.size.height);
	} else {
		if(!frame.size.width && !frame.size.height) {
			self.frame = CGRectMake(frame.origin.x, frame.origin.y, image.size.width, image.size.height);
		} else if(frame.size.width && !frame.size.height) {
			self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, floor((image.size.height/image.size.width) * frame.size.width));
		} else if(frame.size.height && !frame.size.width) {
			self.frame = CGRectMake(frame.origin.x, frame.origin.y, floor((image.size.width/image.size.height) * frame.size.height), frame.size.height);
		}
	}
	
	if(!_defaultImage || image != _defaultImage) {
		[self imageViewDidLoadImage:image];
		if([_delegate respondsToSelector:@selector(imageView:didLoadImage:)]) {
			[_delegate imageView:self didLoadImage:image];
		}
	}
}

#pragma mark -
#pragma mark Loading methods

- (BOOL)isLoading {
	return _request ? YES : NO;
}

- (BOOL)isLoaded {
	return self.image && self.image != _defaultImage;
}

- (void)reload {
	if(!_request && _URL) {
		UIImage* image = [[PVURLCache sharedCache] imageForURL:_URL];
		if(image) {
			self.image = image;
		} else {
			PVURLRequest* request = [PVURLRequest requestWithURL:_URL delegate:self];
			request.response = [[[PVURLImageResponse alloc] init] autorelease];
			if(_URL && ![request send]) {
				// Put the default image in place while waiting for the request to load
				if(_defaultImage && self.image != _defaultImage) {
					self.image = _defaultImage;
				}
			}
		}
	}
}

- (void)stopLoading {
	[_request cancel];
}

#pragma mark -
#pragma mark Subclassable notification methods

- (void)imageViewDidStartLoad {
	
}

- (void)imageViewDidLoadImage:(UIImage*)image {
	
}

- (void)imageViewDidFailLoadWithError:(NSError*)error {
	
}

#pragma mark -
#pragma mark Layer/Drawing methods

- (void)updateLayer {
    // This is dramatically faster than calling drawRect.
	PVImageLayer* layer = (PVImageLayer*)self.layer;
    layer.override = self;
	[layer setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
}

+ (Class)layerClass {
	return [PVImageLayer class];
}


#pragma mark -

- (void)dealloc {
	_delegate = nil;
	[_request cancel];
	PV_RELEASE_SAFELY(_request);
	PV_RELEASE_SAFELY(_URL);
	PV_RELEASE_SAFELY(_image);
	PV_RELEASE_SAFELY(_defaultImage);
	[super dealloc];
}

@end
