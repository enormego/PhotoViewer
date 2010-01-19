//
//  EGOPhotoCaptionView.h
//  EGOPhotoViewer
//
//  Created by Devin Doty on 1/16/10January16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EGOPhotoCaptionView : UIView {
@private
	UILabel *_textLabel;

}

- (void)setCaptionText:(NSString*)text;
- (void)setCaptionHidden:(BOOL)hidden;
@end
