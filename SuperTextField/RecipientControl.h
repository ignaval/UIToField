//
//  RecipientView.h
//  MultiRecipientPicker
//
//  Created by Joe Michels on 5/14/10.
//  Copyright 2010 Software Ops LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// This view will be the container view for and edit field to add addresses, a button to add
// an address from the Contacts app, and it will also show selected recipients using a RecipientViewCell.
// This view will be controlled by the MultiRecipientPickerViewController

@protocol RecipientControlDelegate;
@class RecipientViewCell;

@interface RecipientControl : UIControl 
{
	UIButton		*addFromAddressBookButton;
	UITextField		*entryField;
	UILabel			*toLabel;
	id<RecipientControlDelegate> delegate;
	RecipientViewCell	*selectedRecipientCell;
	CGFloat			defaultHeight;
}


@property (nonatomic, retain) IBOutlet UIButton			*addFromAddressBookButton;
@property (nonatomic, retain) IBOutlet UITextField		*entryField;
@property (nonatomic, retain) IBOutlet UILabel			*toLabel;
@property (nonatomic, assign) IBOutlet id<RecipientControlDelegate> delegate;

@property (nonatomic, retain) RecipientViewCell			*selectedRecipientCell;
@property (nonatomic, assign) CGFloat					defaultHeight;

@end


@protocol RecipientControlDelegate 

- (void)recipientViewFrameDidChange;
- (void)recipientViewCellWasSelected:(RecipientViewCell*)recipientCell;
- (void)recipientViewHit;

@end