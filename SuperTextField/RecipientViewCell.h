//
//  RecipientViewCell.h
//  MultiRecipientPicker
//
//  Created by Joe Michels on 5/14/10.
//  Copyright 2010 Software Ops LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// The RecipientViewCell is the view that displays the recipient in a round rect
// to show it is a unique recipient. The cell can be selected and then deleteded
// with the delete key. The deleting is controlled by the MultiRecipientPickerViewController.

// If the email address is in the form of "First Last <xxxxxx@email.com>" then First Last will
// be displayed, otherwise just the email address will be displayed

@interface RecipientViewCell : UIControl
{
	NSString	*cellDisplayTitle;	
	CGSize		titleSize;

}

- (id)initWithTitle:(NSString*)title;

@property (nonatomic, copy) NSString			*cellDisplayTitle;
@property (nonatomic, assign) CGSize			titleSize;

@end

