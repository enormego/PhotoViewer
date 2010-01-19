//
//  EGOPhotoSource.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import "EGOPhotoSource.h"
#import "EGOImageLoader.h"
#import "EGOCache.h"
#import "EGOPhoto.h"

@implementation EGOPhotoSource

@synthesize photos=_photos;

- (id)initWithEGOPhotos:(NSArray*)thePhotos{
	if (self = [super init]) {
		_photos = [thePhotos retain];
	}
	return self;
}

- (EGOPhoto*)photoAtIndex:(NSInteger)index{
	return [self.photos objectAtIndex:index];
}

- (NSInteger)count{
	return [self.photos count];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"%@, %i Photos", [super description], [self.photos count], nil];
}

- (void)dealloc{
	[_photos release], _photos=nil;
	[super dealloc];
}

@end
