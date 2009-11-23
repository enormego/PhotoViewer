#import "PVModel.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

#define PV_NULL_PHOTO_INDEX NSIntegerMax

@protocol PVPhoto;
@class PVURLRequest;

typedef enum {
  PVPhotoVersionNone,
  PVPhotoVersionLarge,
  PVPhotoVersionMedium,
  PVPhotoVersionSmall,
  PVPhotoVersionThumbnail
} PVPhotoVersion;

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol PVPhotoSource <PVModel>

/**
 * The title of this collection of photos.
 */
@property(nonatomic,copy) NSString* title;

/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
@property(nonatomic,readonly) NSInteger numberOfPhotos;

/**
 * The maximum index of photos that have already been loaded.
 */
@property(nonatomic,readonly) NSInteger maxPhotoIndex;

/**
 *
 */
- (id<PVPhoto>)photoAtIndex:(NSInteger)index;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol PVPhoto <NSObject>

/**
 * The photo source that the photo belongs to.
 */
@property(nonatomic,assign) id<PVPhotoSource> photoSource;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) CGSize size;

/**
 * The index of the photo within its photo source.
 */
@property(nonatomic) NSInteger index;

/**
 * The caption of the photo.
 */
@property(nonatomic,copy) NSString* caption;

/**
 * Gets the URL of one of the differently sized versions of the photo.
 */
- (NSString*)URLForVersion:(PVPhotoVersion)version;

@end
