#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewControllerAdditions.h"
#import "UIToolbarAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define PV_ERROR_DOMAIN @"google.com"

#define PV_EC_INVALID_IMAGE 101

///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

#define PV_ROW_HEIGHT 44
#define PV_TOOLBAR_HEIGHT 44
#define PV_LANDSCAPE_TOOLBAR_HEIGHT 33
#define PV_KEYBOARD_HEIGHT 216
#define PV_LANDSCAPE_KEYBOARD_HEIGHT 160
#define PV_ROUNDED -1

///////////////////////////////////////////////////////////////////////////////////////////////////
// Networking

typedef enum {
   PVURLRequestCachePolicyNone = 0,
   PVURLRequestCachePolicyMemory = 1,
   PVURLRequestCachePolicyDisk = 2,
   PVURLRequestCachePolicyNetwork = 4,
   PVURLRequestCachePolicyNoCache = 8,    
   PVURLRequestCachePolicyLocal
    = (PVURLRequestCachePolicyMemory|PVURLRequestCachePolicyDisk),
   PVURLRequestCachePolicyDefault
    = (PVURLRequestCachePolicyMemory|PVURLRequestCachePolicyDisk|PVURLRequestCachePolicyNetwork),
} PVURLRequestCachePolicy;

#define PV_DEFAULT_CACHE_INVALIDATION_AGE (60*60*24) // 1 day
#define PV_DEFAULT_CACHE_EXPIRATION_AGE (60*60*24*7) // 1 week
#define PV_CACHE_EXPIRATION_AGE_NEVER (1.0 / 0.0)    // inf

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration for transition animations.
 */
#define PV_TRANSITION_DURATION 0.3

#define PV_FAST_TRANSITION_DURATION 0.2

#define PV_FLIP_TRANSITION_DURATION 0.7

///////////////////////////////////////////////////////////////////////////////////////////////////

#define PV_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define PV_AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#define PV_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define PV_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 */
NSMutableArray* PVCreateNonRetainingArray();

/**
 * Creates a mutable dictionary which does not retain references to the values it contains.
 */
NSMutableDictionary* PVCreateNonRetainingDictionary();

/**
 * Tests if an object is an array which is empty.
 */
BOOL PVIsEmptyArray(id object);

/**
 * Tests if an object is a set which is empty.
 */
BOOL PVIsEmptyArray(id object);

/**
 * Tests if an object is a string which is empty.
 */
BOOL PVIsEmptyString(id object);

/**
 * Tests if the device has phone capabilities.
 */
BOOL PVIsPhoneSupported();

/**
 * Gets the current device orientation.
 */
UIDeviceOrientation PVDeviceOrientation();

/**
 * Gets the current interface orientation.
 */
UIInterfaceOrientation PVInterfaceOrientation();

/**
 * Checks if the orientation is portrait, landscape left, or landscape right.
 *
 * This helps to ignore upside down and flat orientations.
 */
BOOL PVIsSupportedOrientation(UIInterfaceOrientation orientation);

/**
 * Gets the rotation transform for a given orientation.
 */
CGAffineTransform PVRotateTransformForOrientation(UIInterfaceOrientation orientation);

/**
 * Gets the bounds of the screen with device orientation factored in.
 */
CGRect PVScreenBounds();

/**
 * Gets the application frame.
 */
CGRect PVApplicationFrame();

/**
 * Gets the application frame below the navigation bar.
 */
CGRect PVNavigationFrame();

/**
 * Gets the application frame below the navigation bar and above the keyboard.
 */
CGRect PVKeyboardNavigationFrame();

/**
 * Gets the application frame below the navigation bar and above a toolbar.
 */
CGRect PVToolbarNavigationFrame();

/**
 * The height of the area containing the status bar and possibly the in-call status bar.
 */
CGFloat PVStatusHeight();

/**
 * The height of the area containing the status bar and navigation bar.
 */
CGFloat PVBarsHeight();

/**
 * The height of a toolbar.
 */
CGFloat PVToolbarHeight();
CGFloat PVToolbarHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * The height of the keyboard.
 */
CGFloat PVKeyboardHeight();
CGFloat PVKeyboardHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * Returns a rectangle that is smaller or larger than the source rectangle.
 */
CGRect PVRectContract(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose edges have been moved a distance and shortened by that distance.
 */
CGRect PVRectShift(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rectangle whose edges have been added to the insets.
 */
CGRect PVRectInset(CGRect rect, UIEdgeInsets insets);
 
/**
 * Increment the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void PVNetworkRequestStarted();

/**
 * Decrement the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void PVNetworkRequestStopped();

/**
 * Gets the current system locale chosen by the user.
 *
 * This is necessary because [NSLocale currentLocale] always returns en_US.
 */
NSLocale* PVCurrentLocale();

/**
 * Returns a localized string from the Three20 bundle.
 */
NSString* PVLocalizedString(NSString* key, NSString* comment);

NSString* PVDescriptionForError(NSError* error);

NSString* PVFormatInteger(NSInteger num);

BOOL PVIsBundleURL(NSString* URL);

BOOL PVIsDocumentsURL(NSString* URL);

NSString* PVPathForBundleResource(NSString* relativePath);

NSString* PVPathForDocumentsResource(NSString* relativePath);

void PVSwapMethods(Class cls, SEL originalSel, SEL newSel);
