#import "PVURLRequest.h"

/**
 * PVModel describes the state of an object that can be loaded from a remote source.
 *
 * By implementing this protocol, you can communicate to the user the state of network
 * activity in an object.
 */
@protocol PVModel <NSObject>

/** 
 * An array of objects that conform to the PVModelDelegate protocol.
 */
- (NSMutableArray*)delegates;

/**
 * Indicates that the data has been loaded.
 */

- (BOOL)isLoaded;

/**
 * Indicates that the data is in the process of loading.
 */
- (BOOL)isLoading;

/**
 * Indicates that the data is in the process of loading additional data.
 */
- (BOOL)isLoadingMore;

/**
 * Indicates that the model is of date and should be reloaded as soon as possible.
 */
-(BOOL)isOutdated;

/**
 * Loads the model.
 */
- (void)load:(PVURLRequestCachePolicy)cachePolicy more:(BOOL)more;

/**
 * Cancels a load that is in progress.
 */
- (void)cancel;

/**
 * Invalidates data stored in the cache or optionally erases it.
 */
- (void)invalidate:(BOOL)erase;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol PVModelDelegate <NSObject>

@optional

/**
 *
 */
- (void)modelDidStartLoad:(id<PVModel>)model;

/**
 *
 */
- (void)modelDidFinishLoad:(id<PVModel>)model;

/**
 *
 */
- (void)model:(id<PVModel>)model didFailLoadWithError:(NSError*)error;

/**
 *
 */
- (void)modelDidCancelLoad:(id<PVModel>)model;

/**
 * Informs the delegate that the model has changed in some fundamental way.
 *
 * The change is not described specifically, so the delegate must assume that the entire
 * contents of the model may have changed, and react almost as if it was given a new model.
 */
- (void)modelDidChange:(id<PVModel>)model;

/**
 *
 */
- (void)model:(id<PVModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
- (void)model:(id<PVModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
- (void)model:(id<PVModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Informs the delegate that the model is about to begin a multi-stage update.
 *
 * Models should use this method to condense multiple updates into a single visible update.
 * This avoids having the view update multiple times for each change.  Instead, the user will
 * only see the end result of all of your changes when you call modelDidEndUpdates.
 */
- (void)modelDidBeginUpdates:(id<PVModel>)model;

/**
 * Informs the delegate that the model has completed a multi-stage update.
 *
 * The exact nature of the change is not specified, so the receiver should investigate the
 * new state of the model by examining its properties.
 */
- (void)modelDidEndUpdates:(id<PVModel>)model;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * A default implementation of PVModel does nothing other than appear to be loaded.
 */
@interface PVModel : NSObject <PVModel> {
  NSMutableArray* _delegates;
}

/**
 * Notifies delegates that the model started to load.
 */
- (void)didStartLoad;

/**
 * Notifies delegates that the model finished loading
 */
- (void)didFinishLoad;

/**
 * Notifies delegates that the model failed to load.
 */
- (void)didFailLoadWithError:(NSError*)error;

/**
 * Notifies delegates that the model canceled its load.
 */
- (void)didCancelLoad;

/**
 * Notifies delegates that the model has begun making multiple updates.
 */
- (void)beginUpdates;

/**
 * Notifies delegates that the model has completed its updates.
 */
- (void)endUpdates;

/**
 * Notifies delegates that an object was updated.
 */
- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was inserted.
 */
- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that an object was deleted.
 */
- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Notifies delegates that the model changed in some fundamental way.
 */
- (void)didChange;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * An implementation of PVModel which is built to work with PVURLRequests.
 *
 * If you use a PVURLRequestModel as the delegate of your PVURLRequests, it will automatically
 * manage many of the PVModel properties based on the state of your requests.
 */
@interface PVURLRequestModel : PVModel <PVURLRequestDelegate> {
  PVURLRequest* _loadingRequest;
  NSDate* _loadedTime;
  NSString* _cacheKey;
  BOOL _isLoadingMore;
  BOOL _hasNoMore;
}

@property(nonatomic,retain) NSDate* loadedTime;
@property(nonatomic,copy) NSString* cacheKey;
@property(nonatomic) BOOL hasNoMore;

/**
 * Resets the model to its original state before any data was loaded.
 */
- (void)reset;

@end

