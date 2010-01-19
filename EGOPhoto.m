//
//  EGOPhoto.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import "EGOPhoto.h"


@implementation EGOPhoto

@synthesize imageURL=_imageURL, imageName=_imageName, image=_image;

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName image:(UIImage*)aImage{
	
	if (self = [super init]) {
		
		_imageURL=[aURL retain];
		_imageName=[aName retain];
		_image=[aImage retain];
 
	}

	return self;
}

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName{
	return [self initWithImageURL:aURL name:aName image:nil];
}

- (id)initWithImageURL:(NSURL*)aURL{
	return [self initWithImageURL:aURL name:nil image:nil];
}

- (BOOL)isEqual:(id)object{
	if ([object isKindOfClass:[EGOPhoto class]]) {
		if (((EGOPhoto*)object).imageURL == self.imageURL) {
			return YES;
		}
	}
		 
	return NO;
}

- (NSString*)description{
	return [NSString stringWithFormat:@"%@ , %@", [super description], self.imageURL];
}

- (void)dealloc{
	[_imageURL release]; _imageURL=nil;
	[_imageName release]; _imageName=nil;
	[_image release]; _image=nil;
	
	[super dealloc];
}

@end
