//
//  RootViewController.m
//  MyPhotoViewerDemo_iPad
//
//  Created by enormego on 4/10/10April10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "EGOPhotoGlobal.h"
#import "MyPhotoSource.h"
#import "MyPhoto.h"

@implementation RootViewController

@synthesize detailViewController;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"MyPhotoViewer";
	
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
}

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

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
  	cell.textLabel.text = indexPath.row == 0 ? @"Photos" : @"Single Photo";
	
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	
	if (indexPath.row == 0) {
		
		MyPhoto *photo = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:@"http://a3.twimg.com/profile_images/66601193/cactus.jpg"] name:@" laksd;lkas;dlkaslkd ;a"];
		MyPhoto *photo2 = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:@"https://s3.amazonaws.com/twitter_production/profile_images/425948730/DF-Star-Logo.png"] name:@"lskdjf lksjdhfk jsdfh ksjdhf sjdhf ksjdhf ksdjfh ksdjh skdjfh skdfjh "];
		MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:[NSArray arrayWithObjects:photo, photo2, photo, photo2, photo, photo2, photo, photo2, nil]];
		
		EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
		
		navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		navController.modalPresentationStyle = UIModalPresentationFullScreen;
		[self presentModalViewController:navController animated:YES];
				
		[navController release];
		[photoController release];
		[photo release];
		[photo2 release];
		[source release];
		
		
	} else if (indexPath.row == 1) {
		
		MyPhoto *photo = [[MyPhoto alloc] initWithImageURL:[NSURL URLWithString:@"https://s3.amazonaws.com/twitter_production/profile_images/425948730/DF-Star-Logo.png"]];
		MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:[NSArray arrayWithObjects:photo, nil]];
		EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
		
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
		navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		navController.modalPresentationStyle = UIModalPresentationFullScreen;
		[self presentModalViewController:navController animated:YES];
		
		[navController release];
		[photoController release];
		[photo release];
		[source release];
		
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [detailViewController release];
    [super dealloc];
}


@end

