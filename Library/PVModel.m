#import "PVModel.h"
#import "PVURLCache.h"
#import "PVURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PVModel

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _delegates = nil;
  }
  return self;
}

- (void)dealloc {
  PV_RELEASE_SAFELY(_delegates);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// PVModel

- (NSMutableArray*)delegates {
  if (!_delegates) {
    _delegates = PVCreateNonRetainingArray();
  }
  return _delegates;
}

- (BOOL)isLoaded {
  return YES;
}

- (BOOL)isLoading {
  return NO;
}

- (BOOL)isLoadingMore {
  return NO;
}

- (BOOL)isOutdated {
  return NO;
}

- (void)load:(PVURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}

- (void)cancel {
}

- (void)invalidate:(BOOL)erase {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)didStartLoad {
	[_delegates makeObjectsPerformSelector:@selector(modelDidStartLoad:) withObject:self];
}

- (void)didFinishLoad {
	[_delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)didFailLoadWithError:(NSError*)error {
	for(id<PVModelDelegate> delegate in _delegates) {
		[delegate model:self didFailLoadWithError:error];
	}
}

- (void)didCancelLoad {
	[_delegates makeObjectsPerformSelector:@selector(modelDidCancelLoad:) withObject:self];
}

- (void)beginUpdates {
	[_delegates makeObjectsPerformSelector:@selector(modelDidBeginUpdates:) withObject:self];
}

- (void)endUpdates {
	[_delegates makeObjectsPerformSelector:@selector(modelDidEndUpdates:) withObject:self];
}

- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	for(id<PVModelDelegate> delegate in _delegates) {
		[delegate model:self didUpdateObject:object atIndexPath:indexPath];
	}
}

- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	for(id<PVModelDelegate> delegate in _delegates) {
		[delegate model:self didInsertObject:object atIndexPath:indexPath];
	}
}

- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	for(id<PVModelDelegate> delegate in _delegates) {
		[delegate model:self didDeleteObject:object atIndexPath:indexPath];
	}
}

- (void)didChange {
	[_delegates makeObjectsPerformSelector:@selector(modelDidChange:) withObject:self];
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PVURLRequestModel

@synthesize loadedTime = _loadedTime, cacheKey = _cacheKey, hasNoMore = _hasNoMore;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
  if (self = [super init]) {
    _loadingRequest = nil;
    _isLoadingMore = NO;
    _loadedTime = nil;
    _cacheKey = nil;
  }
  return self;
}

- (void)dealloc {
  [[PVURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [_loadingRequest cancel];
  PV_RELEASE_SAFELY(_loadingRequest);
  PV_RELEASE_SAFELY(_loadedTime);
  PV_RELEASE_SAFELY(_cacheKey);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// PVModel

- (BOOL)isLoaded {
  return !!_loadedTime;
}

- (BOOL)isLoading {
  return !!_loadingRequest;
}

- (BOOL)isLoadingMore {
  return _isLoadingMore;
}

- (BOOL)isOutdated {
  if (!_cacheKey && _loadedTime) {
    return YES;
  } else if (!_cacheKey) {
    return NO;
  } else {
    NSDate* loadedTime = self.loadedTime;
    if (loadedTime) {
      return -[loadedTime timeIntervalSinceNow] > [PVURLCache sharedCache].invalidationAge;
    } else {
      return NO;
    }
  }
}

- (void)cancel {
  [_loadingRequest cancel];
}

- (void)invalidate:(BOOL)erase {
  if (_cacheKey) {
    if (erase) {
      [[PVURLCache sharedCache] removeKey:_cacheKey];
    } else {
      [[PVURLCache sharedCache] invalidateKey:_cacheKey];
    }
    PV_RELEASE_SAFELY(_cacheKey);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// PVURLRequestDelegate

- (void)requestDidStartLoad:(PVURLRequest*)request {
  [_loadingRequest release];
  _loadingRequest = [request retain];
  [self didStartLoad];
}

- (void)requestDidFinishLoad:(PVURLRequest*)request {
  if (!self.isLoadingMore) {
    [_loadedTime release];
    _loadedTime = [request.timestamp retain];
    self.cacheKey = request.cacheKey;
  }
  
  PV_RELEASE_SAFELY(_loadingRequest);
  [self didFinishLoad];
}

- (void)request:(PVURLRequest*)request didFailLoadWithError:(NSError*)error {
  PV_RELEASE_SAFELY(_loadingRequest);
  [self didFailLoadWithError:error];
}

- (void)requestDidCancelLoad:(PVURLRequest*)request {
  PV_RELEASE_SAFELY(_loadingRequest);
  [self didCancelLoad];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)reset {
  PV_RELEASE_SAFELY(_cacheKey);
  PV_RELEASE_SAFELY(_loadedTime);
}

@end

