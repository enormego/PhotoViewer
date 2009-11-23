#import "PhotoViewer/TTGlobal.h"

@class TTTableViewController, TTSearchDisplayController;

/** 
 * A view controller with some useful additions.
 */
@interface TTViewController : UIViewController {
  BOOL _isViewAppearing;
  BOOL _hasViewAppeared;
}

/**
 * The view has appeared at least once.
 */
@property(nonatomic,readonly) BOOL hasViewAppeared;

/**
 * The view is currently visible.
 */
@property(nonatomic,readonly) BOOL isViewAppearing;

@end
