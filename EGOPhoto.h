//
//  EGOPhoto.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EGOPhoto : NSObject {
	
	NSURL *_imageURL;
	NSString *_imageName;
	UIImage *_image;

}

/*
 * info is already loaded, including image
 */
- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName image:(UIImage*)aImage;

/*
 * url and image name
 */
- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName;

/*
 * just a url is provided
 */
- (id)initWithImageURL:(NSURL*)aURL;

@property(nonatomic,retain) NSURL *imageURL;
@property(nonatomic,retain) NSString *imageName;
@property(nonatomic,retain) UIImage *image;

@end
