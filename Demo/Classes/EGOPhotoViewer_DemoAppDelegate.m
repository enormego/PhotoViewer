//
//  EGOPhotoViewer_DemoAppDelegate.m
//  EGOPhotoViewer_Demo
//
//  Created by Devin Doty on 7/3/10July3.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "EGOPhotoViewer_DemoAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"
#import "RootViewController_iPhone.h"


@implementation EGOPhotoViewer_DemoAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;
@synthesize rootViewController_iPhone;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch.
    
    // Add the split view controller's view to the window and display.
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController_iPhone];
		[window addSubview:navController.view];
		
	} else {
		
		[window addSubview:splitViewController.view];
		
	}

#else
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController_iPhone];
	[window addSubview:navController.view];
	
#endif
	

    [window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
	if (splitViewController) {
		[splitViewController release];
	}
	
	if (rootViewController_iPhone) {
		[rootViewController_iPhone release];
	}
	
    [window release];
    [super dealloc];
}


@end

