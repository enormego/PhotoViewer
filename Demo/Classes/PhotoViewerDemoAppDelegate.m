//
//  PhotoViewerDemoAppDelegate.m
//  PhotoViewerDemo
//
//  Created by Shaun Harrison on 11/23/09.
//  Copyright enormego 2009. All rights reserved.
//

#import "PhotoViewerDemoAppDelegate.h"
#import "RootViewController.h"


@implementation PhotoViewerDemoAppDelegate

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

