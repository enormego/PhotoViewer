//
//  PhotoViewerDemoAppDelegate.h
//  PhotoViewerDemo
//
//  Created by Shaun Harrison on 11/23/09.
//  Copyright enormego 2009. All rights reserved.
//

@interface PhotoViewerDemoAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

