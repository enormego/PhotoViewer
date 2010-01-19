//
//  EGOPhotoSource.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EGOPhoto;

@interface EGOPhotoSource : NSObject {
@private
	NSArray *_photos;
	
}

@property(nonatomic,retain) NSArray *photos;

- (id)initWithEGOPhotos:(NSArray*)photos;
- (EGOPhoto*)photoAtIndex:(NSInteger)index;
- (NSInteger)count;

@end
