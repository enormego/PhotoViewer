//
//  DetailViewController.m
//  EGOPhotoViewerDemo_iPad
//
//  Created by enormego on 4/10/10April10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "EGOPhotoViewController.h"

#import "MyPhotoSource.h"
#import "MyPhoto.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation DetailViewController

@synthesize toolbar, popoverController, detailItem, detailDescriptionLabel;

- (void)viewDidLoad{
	[super viewDidLoad];
	
	UIBarButtonItem *imagesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photosButton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showPhotoView:)];
	UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixed.width = 40.0f;
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	[self.toolbar setItems:[NSArray arrayWithObjects:flex, imagesButton, fixed, nil]];
	
	[imagesButton release];
	[flex release];
	
}

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        [self configureView];
    }
	
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


- (void)configureView {
    // Update the user interface for the detail item.
    detailDescriptionLabel.text = [detailItem description];   
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
	
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	
	if (popoverController) {
		[popoverController dismissPopoverAnimated:YES];
	}
	
}

#pragma mark -
#pragma mark EGOPhotoViewer Popover

- (void)showPhotoView:(UIBarButtonItem*)sender{

	
	MyPhoto *webPhoto = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:@"http://a3.twimg.com/profile_images/66601193/cactus.jpg"] name:@" laksd;lkas;dlkaslkd ;a"];
	MyPhoto *filePathPhoto = [[MyPhoto alloc] initWithImageURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"local_image_2" ofType:@"jpg"]]];
	MyPhoto *inMemoryPhoto = [[MyPhoto alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"local_image_1" ofType:@"jpg"]]];

	MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:[NSArray arrayWithObjects:webPhoto, filePathPhoto, inMemoryPhoto, nil]];
	
	EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
	photoController.contentSizeForViewInPopover = CGSizeMake(480.0f, 480.0f);
	
	[webPhoto release];
	[filePathPhoto release];
	[inMemoryPhoto release];	
	[source release];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
	popover.delegate = self;
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	popoverController = popover;
	
	[photoController release];
	[navController release];
	 
}

#pragma mark -
#pragma mark Popover Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController{
	[aPopoverController release];
	popoverController=nil;
}


#pragma mark -
#pragma mark View lifecycle

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory management

/*
 - (void)didReceiveMemoryWarning {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 
 // Release any cached data, images, etc that aren't in use.
 }
 */

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [detailItem release];
    [detailDescriptionLabel release];
    [super dealloc];
}

@end
