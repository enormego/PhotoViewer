//
//  EGOPhotoViewerAppDelegate.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/8/10.
//  Copyright enormego 2010. All rights reserved.
//

@interface EGOPhotoViewerAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

