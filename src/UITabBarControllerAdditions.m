#import "PhotoViewer/UITabBarControllerAdditions.h"
#import "PhotoViewer/UIViewControllerAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UITabBarController (TTCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (UIViewController*)rootControllerForController:(UIViewController*)controller {
  if ([controller canContainControllers]) {
    return controller;
  } else {
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    [navController pushViewController:controller animated:NO];
    return navController;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController (TTCategory)

- (BOOL)canContainControllers {
  return YES;
}

- (UIViewController*)topSubcontroller {
  return self.selectedViewController;
}

- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  self.selectedViewController = controller;
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
  self.selectedViewController = controller;
}

- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}

- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}

- (void)persistNavigationPath:(NSMutableArray*)path {

 }

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setTabURLs:(NSArray*)URLs {

}

@end
