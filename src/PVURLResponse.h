#import "PVGlobal.h"

@class PVURLRequest;

@protocol PVURLResponse <NSObject>

/**
 * Processes the data from a successful request and determines if it is valid.
 *
 * If the data is not valid, return an error.  The data will not be cached if there is an error.
 */
- (NSError*)request:(PVURLRequest*)request processResponse:(NSHTTPURLResponse*)response
            data:(id)data;

@end

@interface PVURLDataResponse : NSObject <PVURLResponse> {
  NSData* _data;
}

@property(nonatomic,readonly) NSData* data;

@end

@interface PVURLImageResponse : NSObject <PVURLResponse> {
  UIImage* _image;
}

@property(nonatomic,readonly) UIImage* image;

@end
