//
//  EGOPhotoViewerAppDelegate.m
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright enormego 2010. All rights reserved.
//

#import "EGOPhotoViewerAppDelegate.h"
#import "RootViewController.h"


@implementation EGOPhotoViewerAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

