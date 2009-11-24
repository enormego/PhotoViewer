#import "PVGlobal.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

static int gNetworkTaskCount = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////

static const void* PVRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void PVReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* PVCreateNonRetainingArray() {
  CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
  callbacks.retain = PVRetainNoOp;
  callbacks.release = PVReleaseNoOp;
  return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

NSMutableDictionary* PVCreateNonRetainingDictionary() {
  CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
  CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
  callbacks.retain = PVRetainNoOp;
  callbacks.release = PVReleaseNoOp;
  return (NSMutableDictionary*)CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &callbacks);
}

BOOL PVIsEmptyArray(id object) {
  return [object isKindOfClass:[NSArray class]] && ![(NSArray*)object count];
}

BOOL PVIsEmptySet(id object) {
  return [object isKindOfClass:[NSSet class]] && ![(NSSet*)object count];
}

BOOL PVIsEmptyString(id object) {
  return [object isKindOfClass:[NSString class]] && ![(NSString*)object length];
}

BOOL PVIsPhoneSupported() {
  NSString *deviceType = [UIDevice currentDevice].model;
  return [deviceType isEqualToString:@"iPhone"];
}

UIDeviceOrientation PVDeviceOrientation() {
  UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
  if (!orient) {
    return UIDeviceOrientationPortrait;
  } else {
    return orient;
  }
}

UIInterfaceOrientation PVInterfaceOrientation() {
  return [UIApplication sharedApplication].statusBarOrientation;
}

BOOL PVIsSupportedOrientation(UIInterfaceOrientation orientation) {
  switch (orientation) {
    case UIInterfaceOrientationPortrait:
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:
      return YES;
    default:
      return NO;
  }
}

CGAffineTransform PVRotateTransformForOrientation(UIInterfaceOrientation orientation) {
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation(M_PI*1.5);
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation(M_PI/2);
  } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return CGAffineTransformMakeRotation(-M_PI);
  } else {
    return CGAffineTransformIdentity;
  }
}

CGRect PVScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIInterfaceOrientationIsLandscape(PVInterfaceOrientation())) {
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }
  return bounds;
}

CGRect PVApplicationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height);
}

CGRect PVNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - PVToolbarHeight());
}

CGRect PVKeyboardNavigationFrame() {
  return PVRectContract(PVNavigationFrame(), 0, PVKeyboardHeight());
}

CGRect PVToolbarNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - PVToolbarHeight()*2);
}

CGFloat PVStatusHeight() {
  UIInterfaceOrientation orientation = PVInterfaceOrientation();
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return [UIScreen mainScreen].applicationFrame.origin.x;
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return -[UIScreen mainScreen].applicationFrame.origin.x;
  } else {
    return [UIScreen mainScreen].applicationFrame.origin.y;
  }
}

CGFloat PVBarsHeight() {
  CGRect frame = [UIApplication sharedApplication].statusBarFrame;
  if (UIInterfaceOrientationIsPortrait(PVInterfaceOrientation())) {
    return frame.size.height + PV_ROW_HEIGHT;
  } else {
    return frame.size.width + PV_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}

CGFloat PVToolbarHeight() {
  return PVToolbarHeightForOrientation(PVInterfaceOrientation());
}

CGFloat PVToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    return PV_ROW_HEIGHT;
  } else {
    return PV_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}

CGFloat PVKeyboardHeight() {
  return PVKeyboardHeightForOrientation(PVInterfaceOrientation());
}

CGFloat PVKeyboardHeightForOrientation(UIInterfaceOrientation orientation) {
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    return PV_KEYBOARD_HEIGHT;
  } else {
    return PV_LANDSCAPE_KEYBOARD_HEIGHT;
  }
}

CGRect PVRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}

CGRect PVRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(PVRectContract(rect, dx, dy), dx, dy);
}

CGRect PVRectInset(CGRect rect, UIEdgeInsets insets) {
  return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top,
                    rect.size.width - (insets.left + insets.right),
                    rect.size.height - (insets.top + insets.bottom));
}

void PVNetworkRequestStarted() {
  if (gNetworkTaskCount++ == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  }
}

void PVNetworkRequestStopped() {
  if (--gNetworkTaskCount == 0) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }
}

void PVAlert(NSString* message) {
  UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:PVLocalizedString(@"Alert", @"")
                                             message:message delegate:nil
                                             cancelButtonTitle:PVLocalizedString(@"OK", @"")
                                             otherButtonTitles:nil] autorelease];
  [alert show];
}

void PVAlertError(NSString* message) {
  UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:PVLocalizedString(@"Alert", @"")
                                              message:message delegate:nil
                                              cancelButtonTitle:PVLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil] autorelease];
  [alert show];
}

float PVOSVersion() {
  return [[[UIDevice currentDevice] systemVersion] floatValue];
}

BOOL PVOSVersionIsAtLeast(float version) {
  #ifdef __IPHONE_3_0
    return 3.0 >= version;
  #endif
  #ifdef __IPHONE_2_2
    return 2.2 >= version;
  #endif
  #ifdef __IPHONE_2_1
    return 2.1 >= version;
  #endif
  #ifdef __IPHONE_2_0
    return 2.0 >= version;
  #endif
  return NO;
}

NSLocale* PVCurrentLocale() {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
  if (languages.count > 0) {
    NSString *currentLanguage = [languages objectAtIndex:0];
    return [[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage] autorelease];
  } else {
    return [NSLocale currentLocale];
  }
}

NSString* PVLocalizedString(NSString* key, NSString* comment) {
	return key;/*
  static NSBundle* bundle = nil;
  if (!bundle) {
    NSString* path = [[[NSBundle mainBundle] resourcePath]
          stringByAppendingPathComponent:@"PhotoViewer.bundle"];
    bundle = [[NSBundle bundleWithPath:path] retain];
  }
  
  return [bundle localizedStringForKey:key value:key table:nil];*/
}

NSString* PVFormatInteger(NSInteger num) {
  NSNumber* number = [NSNumber numberWithInt:num];
  NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:kCFNumberFormatterDecimalStyle];
  [formatter setGroupingSeparator:@","];
  NSString* formatted = [formatter stringForObjectValue:number];
  [formatter release];
  return formatted;
}

NSString* PVDescriptionForError(NSError* error) {
  if ([error.domain isEqualToString:NSURLErrorDomain]) {
    if (error.code == NSURLErrorTimedOut) {
      return PVLocalizedString(@"Connection Timed Out", @"");
    } else if (error.code == NSURLErrorNotConnectedToInternet) {
      return PVLocalizedString(@"No Internet Connection", @"");
    } else {
      return PVLocalizedString(@"Connection Error", @"");
    }
  }
  return PVLocalizedString(@"Error", @"");
}

BOOL PVIsBundleURL(NSString* URL) {
  if (URL.length >= 9) {
    return [URL rangeOfString:@"bundle://" options:0 range:NSMakeRange(0,9)].location == 0;
  } else {
    return NO;
  }
}

BOOL PVIsDocumentsURL(NSString* URL) {
  if (URL.length >= 12) {
    return [URL rangeOfString:@"documents://" options:0 range:NSMakeRange(0,12)].location == 0;
  } else {
    return NO;
  }
}

NSString* PVPathForBundleResource(NSString* relativePath) {
  NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
  return [resourcePath stringByAppendingPathComponent:relativePath];
}

NSString* PVPathForDocumentsResource(NSString* relativePath) {
  static NSString* documentsPath = nil;
  if (!documentsPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsPath = [[dirs objectAtIndex:0] retain];
  }
  return [documentsPath stringByAppendingPathComponent:relativePath];
}

void PVSwapMethods(Class cls, SEL originalSel, SEL newSel) {
  Method originalMethod = class_getInstanceMethod(cls, originalSel);
  Method newMethod = class_getInstanceMethod(cls, newSel);
  method_exchangeImplementations(originalMethod, newMethod);
}
