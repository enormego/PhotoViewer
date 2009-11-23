#import "PhotoViewer/TTGlobal.h"

@implementation NSMutableArray (TTCategory)

- (void) addNonEmptyString:(NSString*)string {
  if (nil != string && !TTIsEmptyString(string)) {
    [self addObject:string];
  }
}

@end
