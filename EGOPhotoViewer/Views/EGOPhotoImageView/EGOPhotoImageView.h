//
//  EGOPhotoImageView.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/13/2010.
//  Copyright (c) 2008-2009 enormego
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


#import "EGOPhotoGlobal.h"
#import "EGOPhotoSource.h"
#import "EGOImageLoader.h"

@class EGOPhotoScrollView, EGOPhotoCaptionView;

@interface EGOPhotoImageView : UIView <EGOImageLoaderObserver, UIScrollViewDelegate>{
@private
	EGOPhotoScrollView *_scrollView;
	id <EGOPhoto> _photo;
	UIImageView *_imageView;
	UIActivityIndicatorView *_activityView;
	
	BOOL _loading;
	CGRect _currentRect;
	CGFloat _beginRadians;
	CGPoint _midPos;
	
}

@property(nonatomic,readonly) id <EGOPhoto> photo;
@property(nonatomic,readonly) UIImageView *imageView;
@property(nonatomic,readonly) EGOPhotoScrollView *scrollView;
@property(nonatomic,assign,getter=isLoading) BOOL loading;

- (void)setPhoto:(id <EGOPhoto>)aPhoto;
- (void)killScrollViewZoom;
- (void)layoutScrollViewAnimated:(BOOL)animated;
- (void)prepareForReusue;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (CGSize)sizeForPopover;

@end
