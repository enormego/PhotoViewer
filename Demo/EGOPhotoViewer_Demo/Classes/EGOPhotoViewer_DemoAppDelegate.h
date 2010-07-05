//
//  EGOPhotoViewer_DemoAppDelegate.h
//  EGOPhotoViewer_Demo
//
//  Created by Devin Doty on 7/3/10July3.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RootViewController;
@class DetailViewController;
@class RootViewController_iPhone;

@interface EGOPhotoViewer_DemoAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    RootViewController *rootViewController;
    DetailViewController *detailViewController;
	
	RootViewController_iPhone *rootViewController_iPhone;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet UIViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@property (nonatomic, retain) IBOutlet RootViewController_iPhone *rootViewController_iPhone;

@end
