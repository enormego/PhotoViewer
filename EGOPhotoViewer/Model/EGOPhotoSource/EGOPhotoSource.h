//
//  EGOPhotoSource.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 7/3/10.
//  Copyright 2010 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#pragma mark EGOPhotoSource

@protocol EGOPhotoSource <NSObject>

/*
 * Array containing photo data objects.
 */
@property(nonatomic,readonly,retain) NSArray *photos;

/*
 * Number of photos.
 */
@property(nonatomic,readonly) NSInteger numberOfPhotos;

/*
 * Should return a photo from the photos array, at the index passed.
 */
- (id)photoAtIndex:(NSInteger)index;

@end


#pragma mark -
#pragma mark EGOPhoto

@protocol EGOPhoto <NSObject>

/*
 * URL of the image, varied URL size should set according to display size. 
 */
@property(nonatomic,readonly,retain) NSURL *URL;

/*
 * The caption of the image.
 */
@property(nonatomic,readonly,retain) NSString *caption;

/*
 * Size of the image, CGRectZero if image is nil.
 */
@property(nonatomic) CGSize size;

/*
 * The image after being loaded, or local.
 */
@property(nonatomic,retain) UIImage *image;

/*
 * Returns true if the image failed to load.
 */
@property(nonatomic,assign,getter=didFail) BOOL failed;


@end
