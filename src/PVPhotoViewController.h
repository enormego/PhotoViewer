#import "PVPhotoSource.h"
#import "PVScrollView.h"
#import "PVThumbsViewController.h"
#import "PVModel.h"

@class PVScrollView, PVPhotoView;

@interface PVPhotoViewController : UIViewController <PVModelDelegate, PVScrollViewDelegate, PVScrollViewDataSource/*, PVThumbsViewControllerDelegate*/> {
	id<PVPhotoSource> _photoSource;
	id<PVPhoto> _centerPhoto;
	NSInteger _centerPhotoIndex;
	UIView* _innerView;
	PVScrollView* _scrollView;
	PVPhotoView* _photoStatusView;
	UIToolbar* _toolbar;
	UIBarButtonItem* _nextButton;
	UIBarButtonItem* _previousButton;
	UIImage* _defaultImage;
	NSString* _statusText;
	PVThumbsViewController* _thumbsController;
	NSTimer* _slideshowTimer;
	NSTimer* _loadTimer;
	BOOL _delayLoad;
	BOOL _isViewAppearing;
	BOOL _hasViewAppeared;
	
	// ModelViewController
	id<PVModel> _model;
	NSError* _modelError;
	
	struct {
		unsigned int isModelDidRefreshInvalid:1;
		unsigned int isModelWillLoadInvalid:1;
		unsigned int isModelDidLoadInvalid:1;
		unsigned int isModelDidLoadFirstTimeInvalid:1;
		unsigned int isModelDidShowFirstTimeInvalid:1;
		unsigned int isViewInvalid:1;
		unsigned int isViewSuspended:1;
		unsigned int isUpdatingView:1;
		unsigned int isShowingEmpty:1;
		unsigned int isShowingLoading:1;
		unsigned int isShowingModel:1;
		unsigned int isShowingError:1;
	} _flags;	
}

/**
 * The source of a sequential photo collection that will be displayed.
 */
@property(nonatomic,retain) id<PVPhotoSource> photoSource;

/**
 * The photo that is currently visible and centered.
 *
 * You can assign this directly to change the photoSource to the one that contains the photo.
 */
@property(nonatomic,retain) id<PVPhoto> centerPhoto;

/**
 * The index of the currently visible photo.
 *
 * Because centerPhoto can be nil while waiting for the source to load the photo, this property
 * must be maintained even though centerPhoto has its own index property.
 */
@property(nonatomic,readonly) NSInteger centerPhotoIndex;

/**
 * The default image to show before a photo has been loaded.
 */
@property(nonatomic,retain) UIImage* defaultImage;


- (id)initWithPhoto:(id<PVPhoto>)photo;
- (id)initWithPhotoSource:(id<PVPhotoSource>)photoSource;

/**
 * Creates a photo view for a new page.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (PVPhotoView*)createPhotoView;

/**
 * Creates the thumbnail controller used by the "See All" button.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (PVThumbsViewController*)createThumbsViewController;

/**
 * Sent to the controller after it moves from one photo to another.
 */
- (void)didMoveToPhoto:(id<PVPhoto>)photo fromPhoto:(id<PVPhoto>)fromPhoto;

/**
 * Shows or hides an activity label on top of the photo.
 */
- (void)showActivity:(NSString*)title;

/**
 * The view has appeared at least once.
 */
@property(nonatomic,readonly) BOOL hasViewAppeared;

/**
 * The view is currently visible.
 */
@property(nonatomic,readonly) BOOL isViewAppearing;

// Model View Controller

/**
 *
 */
@property(nonatomic,retain) id<PVModel> model;

/**
 * An error that occurred while trying to load content.
 */ 
@property(nonatomic, retain) NSError* modelError;

/**
 * Creates the model that the controller manages.
 */
- (void)createModel;

/**
 * Releases the current model and forces the creation of a new model.
 */
- (void)invalidateModel;

/**
 * Indicates whether the model has been created.
 */
- (BOOL)isModelCreated;

/**
 * Indicates that data should be loaded from the model.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (BOOL)shouldLoad;

/**
 * Indicates that data should be reloaded from the model.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (BOOL)shouldReload;

/**
 * Indicates that more data should be loaded from the model.
 *
 * Do not call this directly.  Subclasses should implement this method.
 */
- (BOOL)shouldLoadMore;

/**
 * Tests if it is possible to show the model.
 *
 * After a model has loaded, this method is called to test whether or not to set the model
 * has content that can be shown.  If you return NO, showEmpty: will be called, and if you
 * return YES, showModel: will be called.
 */
- (BOOL)canShowModel;

/**
 * Reloads data from the model.
 */
- (void)reload;

/**
 * Reloads data from the model if it has become out of date.
 */
- (void)reloadIfNeeded;

/**
 * Refreshes the model state and loads new data if necessary.
 */
- (void)refresh;

/**
 * Begins a multi-stage update.
 *
 * You can call this method to make complicated updates more efficient, and to condense
 * multiple changes to your model into a single visual change.  Call endUpdate when you are done
 * to update the view with all of your changes.
 */
- (void)beginUpdates;

/**
 * Ends a multi-stage model update and updates the view to reflect the model.
 *
 * You can call this method to make complicated updates more efficient, and to condense
 * multiple changes to your model into a single visual change.
 */
- (void)endUpdates;

/**
 * Indicates that the model has changed and schedules the view to be updated to reflect it.
 */
- (void)invalidateView;

/** 
 * Immediately creates, loads, and displays the model (if it was not already).
 */
- (void)updateView;

/**
 * Called when the model is refreshed.
 *
 * Subclasses should override this function update parts of the view that may need to changed
 * when there is a new model, or something about the existing model changes. 
 */
- (void)didRefreshModel;

/**
 * Called before the model is asked to load itself.
 *
 * This is not called until after the view has loaded.  If your model starts loading before
 * the view is loaded, this will still be called, but not until after the view is loaded.
 *
 * The default implementation of this method does nothing. Subclasses may override this method
 * to take an appropriate action.
 */
- (void)willLoadModel;

/**
 * Called after the model has loaded, just before it is to be displayed.
 *
 * This is not called until after the view has loaded.  If your model finishes loading before
 * the view is loaded, this will still be called, but not until after the view is loaded.
 *
 * If you refresh a model which is already loaded, this will be called, but the firstTime
 * argument will be false.
 *
 * The default implementation of this method does nothing. Subclasses may override this method
 * to take an appropriate action.
 */
- (void)didLoadModel:(BOOL)firstTime;

/**
 * Called just after a model has been loaded and displayed.
 *
 * The default implementation of this method does nothing. Subclasses may override this method
 * to take an appropriate action.
 */
- (void)didShowModel:(BOOL)firstTime;

/**
 * Shows views to represent the loaded model's content.
 *
 * The default implementation of this method does nothing. Subclasses may override this method
 * to take an appropriate action.
 */
- (void)showModel:(BOOL)show;

/**
 * Shows views to represent the model loading.
 *
 * The default implementation of this method does nothing. Subclasses may override this method
 * to take an appropriate action.
 */
- (void)showLoading:(BOOL)show;

/**
 * Shows views to represent an empty model. 
 *
 * The default implementation of this method does nothing. Subclasses may override this method
 * to take an appropriate action.
 */
- (void)showEmpty:(BOOL)show;

/**
 * Shows views to represent an error that occurred while loading the model.
 */
- (void)showError:(BOOL)show;


@end
