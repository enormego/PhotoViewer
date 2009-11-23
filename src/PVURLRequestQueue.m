#import "PVURLRequestQueue.h"
#import "PVURLRequest.h"
#import "PVURLResponse.h"
#import "PVURLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////
  
static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 300.0;
static const NSInteger kLoadMaxRetries = 2;
static const NSInteger kMaxConcurrentLoads = 5;
static NSUInteger kDefaultMaxContentLength = 150000;

static NSString* kSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2 like Mac OS X;\
 en-us) AppleWebKit/525.181 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20";

static PVURLRequestQueue* gMainQueue = nil;

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface PVRequestLoader : NSObject {
  NSString* _URL;
  PVURLRequestQueue* _queue;
  NSString* _cacheKey;
  PVURLRequestCachePolicy _cachePolicy;
  NSTimeInterval _cacheExpirationAge;
  NSMutableArray* _requests;
  NSURLConnection* _connection;
  NSHTTPURLResponse* _response;
  NSMutableData* _responseData;
  int _retriesLeft;
}

@property(nonatomic,readonly) NSArray* requests;
@property(nonatomic,readonly) NSString* URL;
@property(nonatomic,readonly) NSString* cacheKey;
@property(nonatomic,readonly) PVURLRequestCachePolicy cachePolicy;
@property(nonatomic,readonly) NSTimeInterval cacheExpirationAge;
@property(nonatomic,readonly) BOOL isLoading;

- (id)initForRequest:(PVURLRequest*)request queue:(PVURLRequestQueue*)queue;

- (void)addRequest:(PVURLRequest*)request;
- (void)removeRequest:(PVURLRequest*)request;

- (void)load:(NSURL*)URL;
- (BOOL)cancel:(PVURLRequest*)request;

@end

@implementation PVRequestLoader

@synthesize URL = _URL, requests = _requests, cacheKey = _cacheKey,
  cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge;

- (id)initForRequest:(PVURLRequest*)request queue:(PVURLRequestQueue*)queue {
  if (self = [super init]) {
    _URL = [request.URL copy];
    _queue = queue;
    _cacheKey = [request.cacheKey retain];
    _cachePolicy = request.cachePolicy;
    _cacheExpirationAge = request.cacheExpirationAge;
    _requests = [[NSMutableArray alloc] init];
    _connection = nil;
    _retriesLeft = kLoadMaxRetries;
    _response = nil;
    _responseData = nil;
    [self addRequest:request];
  }
  return self;
}
 
- (void)dealloc {
  [_connection cancel];
  PV_RELEASE_SAFELY(_connection);
  PV_RELEASE_SAFELY(_response);
  PV_RELEASE_SAFELY(_responseData);
  PV_RELEASE_SAFELY(_URL);
  PV_RELEASE_SAFELY(_cacheKey);
  PV_RELEASE_SAFELY(_requests); 
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connectToURL:(NSURL*)URL {
  PVNetworkRequestStarted();

  PVURLRequest* request = _requests.count == 1 ? [_requests objectAtIndex:0] : nil;
  NSURLRequest *URLRequest = [_queue createNSURLRequest:request URL:URL];

  _connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
}

- (void)cancel {
  NSArray* requestsToCancel = [_requests copy];
  for (id request in requestsToCancel) {
    [self cancel:request];
  }
  [requestsToCancel release];
}

- (NSError*)processResponse:(NSHTTPURLResponse*)response data:(id)data {
  for (PVURLRequest* request in _requests) {
    NSError* error = [request.response request:request processResponse:response data:data];
    if (error) {
      return error;
    }
  }
  return nil;
}

- (void)dispatchLoadedBytes:(NSInteger)bytesLoaded expected:(NSInteger)bytesExpected {
  for (PVURLRequest* request in [[_requests copy] autorelease]) {
    request.totalBytesLoaded = bytesLoaded;
    request.totalBytesExpected = bytesExpected;

    for (id<PVURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidUploadData:)]) {
        [delegate requestDidUploadData:request];
      }
    }
  }
}

- (void)dispatchLoaded:(NSDate*)timestamp {
  for (PVURLRequest* request in [[_requests copy] autorelease]) {
    request.timestamp = timestamp;
    request.isLoading = NO;

    for (id<PVURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
        [delegate requestDidFinishLoad:request];
      }
    }
  }
}

- (void)dispatchError:(NSError*)error {
  for (PVURLRequest* request in [[_requests copy] autorelease]) {
    request.isLoading = NO;

    for (id<PVURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate
 
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
  _response = [response retain];
  NSDictionary* headers = [response allHeaderFields];
  int contentLength = [[headers objectForKey:@"Content-Length"] intValue];
  if (contentLength > _queue.maxContentLength && _queue.maxContentLength) {
    [self cancel];
  }

  _responseData = [[NSMutableData alloc] initWithCapacity:contentLength];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
    willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return nil;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  [self dispatchLoadedBytes:totalBytesWritten expected:totalBytesExpectedToWrite];
}
 
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  PVNetworkRequestStopped();

  if (_response.statusCode == 200) {
	  [_queue loader:self didLoadResponse:_response data:_responseData];
  } else {
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_response.statusCode
      userInfo:nil];
    [_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
      withObject:error];
  }

  PV_RELEASE_SAFELY(_responseData);
  PV_RELEASE_SAFELY(_connection);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {  
  PVNetworkRequestStopped();
  
  PV_RELEASE_SAFELY(_responseData);
  PV_RELEASE_SAFELY(_connection);
  
  if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
      && _retriesLeft) {
    // If there is a network error then we will wait and retry a few times just in case
    // it was just a temporary blip in connectivity
    --_retriesLeft;
    [self load:[NSURL URLWithString:_URL]];
  } else {
    [_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
            withObject:error];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isLoading {
  return !!_connection;
}

- (void)addRequest:(PVURLRequest*)request {
  [_requests addObject:request];
}

- (void)removeRequest:(PVURLRequest*)request {
  [_requests removeObject:request];
}

- (void)load:(NSURL*)URL {
  if (!_connection) {
    [self connectToURL:URL];
  }
}

- (BOOL)cancel:(PVURLRequest*)request {
  NSUInteger index = [_requests indexOfObject:request];
  if (index != NSNotFound) {
    request.isLoading = NO;

    for (id<PVURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
        [delegate requestDidCancelLoad:request];
      }
    }

    [_requests removeObjectAtIndex:index];
  }
  if (![_requests count]) {
    [_queue performSelector:@selector(loaderDidCancel:wasLoading:) withObject:self
            withObject:(id)!!_connection];
    if (_connection) {
      PVNetworkRequestStopped();
      [_connection cancel];
      PV_RELEASE_SAFELY(_connection);
    }
    return NO;
  } else {
    return YES;
  }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PVURLRequestQueue

@synthesize maxContentLength = _maxContentLength, userAgent = _userAgent, suspended = _suspended,
  imageCompressionQuality = _imageCompressionQuality;

+ (PVURLRequestQueue*)mainQueue {
  if (!gMainQueue) {
    gMainQueue = [[PVURLRequestQueue alloc] init];
  }
  return gMainQueue;
}

+ (void)setMainQueue:(PVURLRequestQueue*)queue {
  if (gMainQueue != queue) {
    [gMainQueue release];
    gMainQueue = [queue retain];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
  if (self == [super init]) {
    _loaders = [[NSMutableDictionary alloc] init];
    _loaderQueue = [[NSMutableArray alloc] init];
    _loaderQueueTimer = nil;
    _totalLoading = 0;
    _maxContentLength = kDefaultMaxContentLength;
    _imageCompressionQuality = 0.75;
    _userAgent = [kSafariUserAgent copy];
    _suspended = NO;
  }
  return self;
}

- (void)dealloc {
  [_loaderQueueTimer invalidate];
  PV_RELEASE_SAFELY(_loaders);
  PV_RELEASE_SAFELY(_loaderQueue);
  PV_RELEASE_SAFELY(_userAgent);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSData*)loadFromBundle:(NSString*)URL error:(NSError**)error {
  NSString* path = PVPathForBundleResource([URL substringFromIndex:9]);
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    return [NSData dataWithContentsOfFile:path];
  } else if (error) {
    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                      code:NSFileReadNoSuchFileError userInfo:nil];
  }
  return nil;
}

- (NSData*)loadFromDocuments:(NSString*)URL error:(NSError**)error {
  NSString* path = PVPathForDocumentsResource([URL substringFromIndex:12]);
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    return [NSData dataWithContentsOfFile:path];
  } else if (error) {
    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                      code:NSFileReadNoSuchFileError userInfo:nil];
  }
  return nil;
}

- (BOOL)loadFromCache:(NSString*)URL cacheKey:(NSString*)cacheKey
    expires:(NSTimeInterval)expirationAge fromDisk:(BOOL)fromDisk data:(id*)data
    error:(NSError**)error timestamp:(NSDate**)timestamp {
  UIImage* image = [[PVURLCache sharedCache] imageForURL:URL fromDisk:fromDisk];
  if (image) {
    *data = image;
    return YES;    
  } else if (fromDisk) {
    if (PVIsBundleURL(URL)) {
      *data = [self loadFromBundle:URL error:error];
      return YES;
    } else if (PVIsDocumentsURL(URL)) {
      *data = [self loadFromDocuments:URL error:error];
      return YES;
    } else {
      *data = [[PVURLCache sharedCache] dataForKey:cacheKey expires:expirationAge
                                        timestamp:timestamp];
      if (*data) {
        return YES;
      }
    }
  }
  
  return NO;
}

- (BOOL)loadRequestFromCache:(PVURLRequest*)request {
  if (!request.cacheKey) {
    request.cacheKey = [[PVURLCache sharedCache] keyForURL:request.URL];
  }

  if (request.cachePolicy & (PVURLRequestCachePolicyDisk|PVURLRequestCachePolicyMemory)) {
    id data = nil;
    NSDate* timestamp = nil;
    NSError* error = nil;
    
    if ([self loadFromCache:request.URL cacheKey:request.cacheKey
              expires:request.cacheExpirationAge
              fromDisk:!_suspended && request.cachePolicy & PVURLRequestCachePolicyDisk
              data:&data error:&error timestamp:&timestamp]) {
      request.isLoading = NO;

      if (!error) {
        error = [request.response request:request processResponse:nil data:data];
      }
      
      if (error) {
        for (id<PVURLRequestDelegate> delegate in request.delegates) {
          if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
            [delegate request:request didFailLoadWithError:error];
          }
        }
      } else {
        request.timestamp = timestamp ? timestamp : [NSDate date];
        request.respondedFromCache = YES;

        for (id<PVURLRequestDelegate> delegate in request.delegates) {
          if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
            [delegate requestDidFinishLoad:request];
          }
        }
      }
      
      return YES;
    }
  }
  
  return NO;
}

- (void)executeLoader:(PVRequestLoader*)loader {
  id data = nil;
  NSDate* timestamp = nil;
  NSError* error = nil;
  
  if ((loader.cachePolicy & (PVURLRequestCachePolicyDisk|PVURLRequestCachePolicyMemory))
      && [self loadFromCache:loader.URL cacheKey:loader.cacheKey
               expires:loader.cacheExpirationAge
               fromDisk:loader.cachePolicy & PVURLRequestCachePolicyDisk
               data:&data error:&error timestamp:&timestamp]) {
    [_loaders removeObjectForKey:loader.cacheKey];

    if (!error) {
      error = [loader processResponse:nil data:data];
    }
    if (error) {
      [loader dispatchError:error];
    } else {
      [loader dispatchLoaded:timestamp];
    }
  } else {
    ++_totalLoading;
    [loader load:[NSURL URLWithString:loader.URL]];
  }
}

- (void)loadNextInQueueDelayed {
  if (!_loaderQueueTimer) {
    _loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
      selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
  }
}

- (void)loadNextInQueue {
  _loaderQueueTimer = nil;

  for (int i = 0;
       i < kMaxConcurrentLoads && _totalLoading < kMaxConcurrentLoads
       && _loaderQueue.count;
       ++i) {
    PVRequestLoader* loader = [[_loaderQueue objectAtIndex:0] retain];
    [_loaderQueue removeObjectAtIndex:0];
    [self executeLoader:loader];
    [loader release];
  }

  if (_loaderQueue.count && !_suspended) {
    [self loadNextInQueueDelayed];
  }
}

- (void)removeLoader:(PVRequestLoader*)loader {
  --_totalLoading;
  [_loaders removeObjectForKey:loader.cacheKey];
}

- (void)loader:(PVRequestLoader*)loader didLoadResponse:(NSHTTPURLResponse*)response data:(id)data {
  [loader retain];
  [self removeLoader:loader];
  
  NSError* error = [loader processResponse:response data:data];
  if (error) {
    [loader dispatchError:error];
  } else {
    if (!(loader.cachePolicy & PVURLRequestCachePolicyNoCache)) {
      [[PVURLCache sharedCache] storeData:data forKey:loader.cacheKey];
    }
    [loader dispatchLoaded:[NSDate date]];
  }
  [loader release];

  [self loadNextInQueue];
}

- (void)loader:(PVRequestLoader*)loader didFailLoadWithError:(NSError*)error {
  [self removeLoader:loader];
  [loader dispatchError:error];
  [self loadNextInQueue];
}

- (void)loaderDidCancel:(PVRequestLoader*)loader wasLoading:(BOOL)wasLoading {
  if (wasLoading) {
    [self removeLoader:loader];
    [self loadNextInQueue];
  } else {
    [_loaders removeObjectForKey:loader.cacheKey];
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSuspended:(BOOL)isSuspended {
  _suspended = isSuspended;
  
  if (!_suspended) {
    [self loadNextInQueue];
  } else if (_loaderQueueTimer) {
    [_loaderQueueTimer invalidate];
    _loaderQueueTimer = nil;
  }
}

- (BOOL)sendRequest:(PVURLRequest*)request {
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  for (id<PVURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }
  
  if (!request.URL.length) {
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    for (id<PVURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
    return NO;
  }

  request.isLoading = YES;
  
  PVRequestLoader* loader = nil;
  if (![request.httpMethod isEqualToString:@"POST"]) {
    // Next, see if there is an active loader for the URL and if so join that bandwagon
    loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader addRequest:request];
      return NO;
    }
  }

  // Finally, create a new loader and hit the network (unless we are suspended)
  loader = [[PVRequestLoader alloc] initForRequest:request queue:self];
  [_loaders setObject:loader forKey:request.cacheKey];
  if (_suspended || _totalLoading == kMaxConcurrentLoads) {
    [_loaderQueue addObject:loader];
  } else {
    ++_totalLoading;
    [loader load:[NSURL URLWithString:request.URL]];
  }
  [loader release];
  
  return NO;
}

- (void)cancelRequest:(PVURLRequest*)request {
  if (request) {
    PVRequestLoader* loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader retain];
      if (![loader cancel:request]) {
        [_loaderQueue removeObject:loader];
      }
      [loader release];
    }
  }
}

- (void)cancelRequestsWithDelegate:(id)delegate {
  NSMutableArray* requestsToCancel = nil;
  
  for (PVRequestLoader* loader in [_loaders objectEnumerator]) {
    for (PVURLRequest* request in loader.requests) {
      for (id<PVURLRequestDelegate> requestDelegate in request.delegates) {
        if (delegate == requestDelegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
          break;
        }
      }

      if ([request.userInfo isKindOfClass:[PVUserInfo class]]) {
        PVUserInfo* userInfo = request.userInfo;
        if (userInfo.weak && userInfo.weak == delegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
        }
      }
    }
  }
  
  for (PVURLRequest* request in requestsToCancel) {
    [self cancelRequest:request];
  }  
}

- (void)cancelAllRequests {
  for (PVRequestLoader* loader in [[[_loaders copy] autorelease] objectEnumerator]) {
    [loader cancel];
  }
}

- (NSURLRequest*)createNSURLRequest:(PVURLRequest*)request URL:(NSURL*)URL {
  if (!URL) {
    URL = [NSURL URLWithString:request.URL];
  }
  
  NSMutableURLRequest* URLRequest = [NSMutableURLRequest requestWithURL:URL
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:kTimeout];
  [URLRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

  if (request) {
    [URLRequest setHTTPShouldHandleCookies:request.shouldHandleCookies];
    
    NSString* method = request.httpMethod;
    if (method) {
      [URLRequest setHTTPMethod:method];
    }
    
    NSString* contentType = request.contentType;
    if (contentType) {
      [URLRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    
    NSData* body = request.httpBody;
    if (body) {
      [URLRequest setHTTPBody:body];
    }

    NSDictionary* headers = request.headers;
    for (NSString *key in [headers keyEnumerator]) {
      [URLRequest setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
  }
  
  return URLRequest;
}

@end
