#import "PVURLResponse.h"
#import "PVURLRequest.h"
#import "PVURLCache.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PVURLDataResponse

@synthesize data = _data;

- (id)init {
  if (self = [super init]) {
    _data = nil;
  }
  return self;
}

- (void)dealloc {
  PV_RELEASE_SAFELY(_data);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// PVURLResponse

- (NSError*)request:(PVURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  if ([data isKindOfClass:[NSData class]]) {
    _data = [data retain];
  }
  return nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PVURLImageResponse

@synthesize image = _image;

- (id)init {
  if (self = [super init]) {
    _image = nil;
  }
  return self;
}

- (void)dealloc {
  PV_RELEASE_SAFELY(_image);
  [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// PVURLResponse

- (NSError*)request:(PVURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data {
  if ([data isKindOfClass:[UIImage class]]) {
    _image = [data retain];
  } else if ([data isKindOfClass:[NSData class]]) {
    UIImage* image = [[PVURLCache sharedCache] imageForURL:request.URL fromDisk:NO];
    if (!image) {
      image = [UIImage imageWithData:data];
    }
    if (image) {
      if (!request.respondedFromCache) {
        [[PVURLCache sharedCache] storeImage:image forURL:request.URL];
      }
      _image = [image retain];
    } else {
      return [NSError errorWithDomain:PV_ERROR_DOMAIN code:PV_EC_INVALID_IMAGE
                      userInfo:nil];
    }
  }
  return nil;
}

@end

