//
//  RecipientController.h
//  SuperTextField
//
//  Created by ign on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipient.h"

// This view will be the container view for and edit field to add addresses, a button to add
// an address from the Contacts app, and it will also show selected recipients using a RecipientViewCell.
// This view will be controlled by the MultiRecipientPickerViewController

@protocol RecipientControlDelegate;
@class RecipientViewCell;
@protocol DataModelDelegate;

//@protocol DataModelDelegate <NSObject>
//
//@required
//
//- (BOOL)foundMatchesForSearchString:(NSString*)searchString;
//- (NSInteger)countForSearchMatches;
//- (NSString*)personNameForIndex:(NSInteger)index;
//- (NSString*)personAddressForIndex:(NSInteger)index;
//
//- (void)addRecipient:(Recipient*)newRecipient;
//- (void)removeRecipient:(Recipient*)recipient;
//
//- (Recipient*)lastRecipient;
//
//@property (nonatomic, readonly) NSArray *recipients;
//
//@end

@interface RecipientController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
	UIButton		*addFromAddressBookButton;
	UITextField		*entryField;
	UILabel			*toLabel;
    UILabel         *namesLabel;
	id<RecipientControlDelegate> delegate;
	RecipientViewCell	*selectedRecipientCell;
	CGFloat			defaultHeight;
    
    UITableView			*contactMatchListView;
    
    id <DataModelDelegate> model;
}


@property (nonatomic, retain) IBOutlet UIButton			*addFromAddressBookButton;
@property (nonatomic, retain) IBOutlet UITextField		*entryField;
@property (nonatomic, retain) IBOutlet UILabel			*toLabel;
@property (nonatomic, retain) IBOutlet UILabel			*namesLabel;
@property (nonatomic, assign) IBOutlet id<RecipientControlDelegate> delegate;

@property (nonatomic, retain) RecipientViewCell			*selectedRecipientCell;
@property (nonatomic, assign) CGFloat					defaultHeight;

@property (nonatomic, retain) UITableView				*contactMatchListView;

@property (nonatomic, retain) id model;

@end
