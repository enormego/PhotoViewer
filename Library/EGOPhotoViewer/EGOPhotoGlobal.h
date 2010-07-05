/*
 *  EGOPhotoGlobal.h
 *
 *  Created by Devin Doty on 7/3/10July3.
 *  Copyright 2010 enormego. All rights reserved.
 *
 */


// frameworks
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//  controller
#import "EGOPhotoViewController.h"

//  views
#import "EGOPhotoScrollView.h"
#import "EGOPhotoImageView.h"
#import "EGOPhotoCaptionView.h"

//  model
#import "EGOPhotoSource.h"

//  loading and disk I/O 
#import "EGOImageLoadConnection.h"
#import "EGOImageLoader.h"
#import "EGOCache.h"

#define kPhotoErrorPlaceholder [UIImage imageNamed:@"error_placeholder.png"]
#define kPhotoLoadingPlaceholder [UIImage imageNamed:@"photo_placeholder.png"]

#define IMAGE_GAP 30
#define ZOOM_SCALE 2.5

