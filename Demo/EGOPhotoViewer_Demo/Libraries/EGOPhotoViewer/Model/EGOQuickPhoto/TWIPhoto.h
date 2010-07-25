//
//  TWIPhoto.h
//  TWI
//
//  Created by Devin Doty on 7/3/10.
//  Copyright 2010 enormego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGOPhotoGlobal.h"


@interface TWIPhoto : NSObject <EGOPhoto>{
@private
	NSURL *_URL;
	NSString *_caption;
	CGSize _size;
	UIImage *_image;
	
	BOOL _failed;
}

- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName image:(UIImage*)aImage;
- (id)initWithImageURL:(NSURL*)aURL name:(NSString*)aName;
- (id)initWithImageURL:(NSURL*)aURL;
- (id)initWithImage:(UIImage*)aImage;

@end
