#import "UIViewControllerAdditions.h"
#import "PVGlobal.h"

@implementation UIViewController (TVCategory)

- (void)showBars:(BOOL)show animated:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:!show animated:animated];
	
	if(animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:PV_TRANSITION_DURATION];
	}
	
	self.navigationController.navigationBar.alpha = show ? 1 : 0;
	
	if(animated) [UIView commitAnimations];
}

@end