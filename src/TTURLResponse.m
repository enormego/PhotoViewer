#import "TTURLResponse.h"
#import "TTURLRequest.h"
#import "TTURLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLDataResponse

@synthesize data = _data;

- (id)init {
  if (self = [super init]) {
    _data = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_data);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLResponse

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  if ([data isKindOfClass:[NSData class]]) {
    _data = [data retain];
  }
  return nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTURLImageResponse

@synthesize image = _image;

- (id)init {
  if (self = [super init]) {
    _image = nil;
  }
  return self;
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_image);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLResponse

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  if ([data isKindOfClass:[UIImage class]]) {
    _image = [data retain];
  } else if ([data isKindOfClass:[NSData class]]) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:request.URL fromDisk:NO];
    if (!image) {
      image = [UIImage imageWithData:data];
    }
    if (image) {
      if (!request.respondedFromCache) {
        [[TTURLCache sharedCache] storeImage:image forURL:request.URL];
      }
      _image = [image retain];
    } else {
      return [NSError errorWithDomain:TT_ERROR_DOMAIN code:TT_EC_INVALID_IMAGE
                      userInfo:nil];
    }
  }
  return nil;
}

@end

