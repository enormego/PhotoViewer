#import "PVImageView.h"
#import "PVPhotoSource.h"

@protocol PVPhoto;
@class PVActivityLabel, PVLabel;

@interface PVPhotoView : PVImageView <PVImageViewDelegate> {
  id <PVPhoto> _photo;
  UIActivityIndicatorView* _statusSpinner;
  PVLabel* _statusLabel;
  PVLabel* _captionLabel;
  PVPhotoVersion _photoVersion;
  BOOL _hidesExtras;
  BOOL _hidesCaption;
}

@property(nonatomic,retain) id<PVPhoto> photo;
@property(nonatomic) BOOL hidesExtras;
@property(nonatomic) BOOL hidesCaption;

- (BOOL)loadPreview:(BOOL)fromNetwork;
- (void)loadImage;

- (void)showProgress:(CGFloat)progress;
- (void)showStatus:(NSString*)text;

@end
