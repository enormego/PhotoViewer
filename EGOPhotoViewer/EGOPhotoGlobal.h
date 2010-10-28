//
//  EGOPhotoGlobal.h
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

// Frameworks
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// Controller
#import "EGOPhotoViewController.h"

// Views
#import "EGOPhotoScrollView.h"
#import "EGOPhotoImageView.h"
#import "EGOPhotoCaptionView.h"

// Model
#import "EGOPhotoSource.h"
#import "EGOQuickPhoto.h"
#import "EGOQuickPhotoSource.h"

// Loading and Disk I/O 
#import "EGOImageLoadConnection.h"
#import "EGOImageLoader.h"
#import "EGOCache.h"

// Definitions used interally.
// ifndef checks are so you can easily override them in your project.
#ifndef kEGOPhotoErrorPlaceholder
	#define kEGOPhotoErrorPlaceholder [UIImage imageNamed:@"egopv_error_placeholder.png"]
#endif

#ifndef kEGOPhotoLoadingPlaceholder
	#define kEGOPhotoLoadingPlaceholder [UIImage imageNamed:@"egopv_photo_placeholder.png"]
#endif

#ifndef EGOPV_IMAGE_GAP
	#define EGOPV_IMAGE_GAP 30
#endif

#ifndef EGOPV_ZOOM_SCALE
	#define EGOPV_ZOOM_SCALE 2.5
#endif

#ifndef EGOPV_MAX_POPOVER_SIZE
#define EGOPV_MAX_POPOVER_SIZE CGSizeMake(480.0f, 480.0f)
#endif

#ifndef EGOPV_MIN_POPOVER_SIZE
#define EGOPV_MIN_POPOVER_SIZE CGSizeMake(320.0f, 320.0f)
#endif