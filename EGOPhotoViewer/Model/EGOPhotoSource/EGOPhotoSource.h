

#pragma mark -
#pragma mark EGOPhotoSource

@protocol EGOPhotoSource <NSObject>

/*
 * Array containing photo data objects.
 */
@property(nonatomic,readonly) NSArray *photos;

/*
 * Number of photos.
 */
@property(nonatomic,readonly) NSInteger numberOfPhotos;

/*
 * Should return a photo from the photos array, at the index passed.
 */
- (id)photoAtIndex:(NSInteger)index;

@end


#pragma mark -
#pragma mark EGOPhoto

@protocol EGOPhoto <NSObject>

/*
 * URL of the image, varied URL size should set according to display size. 
 */
@property(nonatomic,readonly) NSURL *URL;

/*
 * The caption of the image.
 */
@property(nonatomic,readonly) NSString *caption;

/*
 * Size of the image, CGRectZero if image is nil.
 */
@property(nonatomic) CGSize size;

/*
 * The image after being loaded, or local.
 */
@property(nonatomic,retain) UIImage *image;

/*
 * Returns true if the image failed to load.
 */
@property(nonatomic,assign,getter=didFail) BOOL failed;


@end

