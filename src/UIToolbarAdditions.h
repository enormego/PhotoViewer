#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIToolbar (TVCategory)

- (UIBarButtonItem*)itemWithTag:(NSInteger)tag;

- (void)replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem*)item;

@end
