#import "PhotoViewer/TTTableViewController.h"
#import "PhotoViewer/TTThumbsTableViewCell.h"
#import "PhotoViewer/TTPhotoSource.h"

@protocol TTThumbsViewControllerDelegate, TTPhotoSource;
@class TTPhotoViewController;

@interface TTThumbsViewController : TTTableViewController <TTThumbsTableViewCellDelegate> {
  id<TTThumbsViewControllerDelegate> _delegate;
  id<TTPhotoSource> _photoSource;
}

@property(nonatomic,assign) id<TTThumbsViewControllerDelegate> delegate;
@property(nonatomic,retain) id<TTPhotoSource> photoSource;

- (id)initWithDelegate:(id<TTThumbsViewControllerDelegate>)delegate;
- (id)initWithQuery:(NSDictionary*)query;

- (TTPhotoViewController*)createPhotoViewController;
- (id<TTTableViewDataSource>)createDataSource;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface TTThumbsDataSource : TTTableViewDataSource {
  id<TTThumbsTableViewCellDelegate> _delegate;
  id<TTPhotoSource> _photoSource;
}

@property(nonatomic,assign) id<TTThumbsTableViewCellDelegate> delegate;
@property(nonatomic,retain) id<TTPhotoSource> photoSource;

- (id)initWithPhotoSource:(id<TTPhotoSource>)photoSource
      delegate:(id<TTThumbsTableViewCellDelegate>)delegate;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol TTThumbsViewControllerDelegate <NSObject>

- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo;

@optional

- (BOOL)thumbsViewController:(TTThumbsViewController*)controller
        shouldNavigateToPhoto:(id<TTPhoto>)photo;

@end
