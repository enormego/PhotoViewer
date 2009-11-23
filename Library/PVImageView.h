#import "PVView.h"
#import "PVURLRequest.h"

@protocol PVImageViewDelegate;

@interface PVImageView : PVView <PVURLRequestDelegate> {
  id<PVImageViewDelegate> _delegate;
  PVURLRequest* _request;
  NSString* _URL;
  UIImage* _image;
  UIImage* _defaultImage;
  BOOL _autoresizesToImage;
}

@property(nonatomic,assign) id<PVImageViewDelegate> delegate;
@property(nonatomic,copy) NSString* URL;
@property(nonatomic,retain) UIImage* image;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic) BOOL autoresizesToImage;
@property(nonatomic,readonly) BOOL isLoading;
@property(nonatomic,readonly) BOOL isLoaded;

- (void)reload;
- (void)stopLoading;

- (void)imageViewDidStartLoad;
- (void)imageViewDidLoadImage:(UIImage*)image;
- (void)imageViewDidFailLoadWithError:(NSError*)error;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol PVImageViewDelegate <NSObject>

@optional

- (void)imageView:(PVImageView*)imageView didLoadImage:(UIImage*)image;
- (void)imageViewDidStartLoad:(PVImageView*)imageView;
- (void)imageView:(PVImageView*)imageView didFailLoadWithError:(NSError*)error;

@end
